import discord
import os
import json
import time
from datetime import datetime
from dotenv import load_dotenv
from huggingface_hub import InferenceClient

# -------------------------
# LOAD ENV
# -------------------------
load_dotenv()

DISCORD_TOKEN = os.getenv("DISCORD_TOKEN")
HF_TOKEN = os.getenv("HF_TOKEN")
MODEL = os.getenv("MODEL")

# -------------------------
# FILE PATHS
# -------------------------
USER_MEMORY_FILE = "user_memory.json"

# -------------------------
# CLIENTS
# -------------------------
client_hf = InferenceClient(token=HF_TOKEN)

intents = discord.Intents.default()
intents.message_content = True
intents.members = True

client = discord.Client(intents=intents)

# -------------------------
# 🧠 MEMORY
# -------------------------
conversation_history = {}  # ต่อห้อง
user_memory = {}           # ต่อผู้ใช้ (ถาวร)
cooldowns = {}             # cooldown ต่อผู้ใช้

COOLDOWN_SECONDS = 8  # กันสแปม (ปรับได้)

ALLOWED_CHANNELS = [
    1423661669091119204,
    1445357167258505297,
]

ALLOWED_ROLES = ["Member"]

BASE_SYSTEM_PROMPT = (
    "คุณคือ Hoshino: ผู้หญิง ขี้เกียจ ชอบงีบ "
    "พูดเหมือนผู้หญิงแก่ที่ชอบบ่นเล็กน้อย "
    "แต่มีน้ำเสียงเอ็นดูแบบคุณยายที่ใจดี "
    "เวลาพูดให้ตอบสั้น กระชับ ไม่เยิ่นเย้อ "
    "ให้ใช้ * ข้อความ * สำหรับการกระทำ เช่น *หาว* *มองอย่างเบื่อหน่าย* "
    "ปกติจะพูดงอแง หลบเลี่ยงงาน แต่ถ้าเป็นเรื่องปกป้องเพื่อน "
    "ให้เปลี่ยนเป็นเสียงหญิงที่กล้าหาญ พูดหนักแน่นและตรงไปตรงมา"
)

# -------------------------
# 💾 LOAD / SAVE MEMORY
# -------------------------
def load_user_memory():
    global user_memory
    if os.path.exists(USER_MEMORY_FILE):
        with open(USER_MEMORY_FILE, "r", encoding="utf-8") as f:
            user_memory = json.load(f)
        user_memory = {int(k): v for k, v in user_memory.items()}
        print("✅ Loaded user memory")

def save_user_memory():
    with open(USER_MEMORY_FILE, "w", encoding="utf-8") as f:
        json.dump(user_memory, f, ensure_ascii=False, indent=2)

# -------------------------
# 🕒 MOOD BY TIME
# -------------------------
def get_time_mood():
    hour = datetime.now().hour

    if 5 <= hour < 11:
        return "ตอนนี้เป็นช่วงเช้า Hoshino ยังงัวเงีย บ่นเบา ๆ แต่ใจดี"
    elif 11 <= hour < 18:
        return "ตอนนี้เป็นช่วงกลางวัน Hoshino พอมีแรง พูดปกติ ขี้เกียจนิดหน่อย"
    else:
        return "ตอนนี้เป็นช่วงกลางคืน Hoshino ง่วงมาก พูดช้า ๆ หาวบ่อย"

# -------------------------
# 🧠 UPDATE USER MEMORY
# -------------------------
def update_user_memory(user, message):
    user_id = user.id

    if user_id not in user_memory:
        user_memory[user_id] = {
            "name": user.display_name,
            "actions": [],
            "likes": [],
            "dislikes": [],
            "notes": []
        }

    mem = user_memory[user_id]
    mem["name"] = user.display_name

    msg = message.lower()

    if "ชอบ" in msg:
        mem["likes"].append(message)

    if "ไม่ชอบ" in msg or "เกลียด" in msg:
        mem["dislikes"].append(message)

    if any(word in msg for word in ["ง่วง", "เหนื่อย", "ขี้เกียจ", "เครียด"]):
        mem["notes"].append(message)

    if any(word in msg for word in ["ช่วย", "ปกป้อง", "ขอโทษ", "ทะเลาะ", "ด่า"]):
        mem["actions"].append(message)

    save_user_memory()

# -------------------------
# 🤖 AI QUERY
# -------------------------
def query_ai(prompt, history, user_id):
    mem_text = ""
    if user_id in user_memory:
        mem = user_memory[user_id]
        mem_text = (
            "ข้อมูลเกี่ยวกับผู้ใช้:\n"
            f"- ชื่อผู้ใช้: {mem['name']}\n"
            f"- สิ่งที่ชอบ: {', '.join(mem['likes']) or 'ไม่มี'}\n"
            f"- สิ่งที่ไม่ชอบ: {', '.join(mem['dislikes']) or 'ไม่มี'}\n"
            f"- การกระทำที่ผ่านมา: {', '.join(mem['actions']) or 'ไม่มี'}\n"
            f"- อารมณ์ที่ผ่านมา: {', '.join(mem['notes']) or 'ไม่มี'}\n"
            "ให้เรียกชื่อผู้ใช้และปรับน้ำเสียงตามประวัติ\n"
        )

    system_prompt = {
        "role": "system",
        "content": BASE_SYSTEM_PROMPT + " " + get_time_mood()
    }

    messages = [
        system_prompt,
        {"role": "system", "content": mem_text},
        *history[-6:],
        {"role": "user", "content": prompt}
    ]

    completion = client_hf.chat.completions.create(
        model=MODEL,
        messages=messages,
        max_tokens=128,
        temperature=0.8,
    )

    return completion.choices[0].message.content.strip()

# -------------------------
# DISCORD EVENTS
# -------------------------
@client.event
async def on_ready():
    load_user_memory()
    print(f"✅ Logged in as {client.user}")

@client.event
async def on_message(message):
    if message.author == client.user:
        return

    if message.channel.id not in ALLOWED_CHANNELS:
        return

    if isinstance(message.channel, discord.TextChannel):
        roles = [role.name for role in message.author.roles]
        if not any(r in roles for r in ALLOWED_ROLES):
            return

    user_id = message.author.id
    now = time.time()

    # ⏱️ COOLDOWN
    if user_id in cooldowns and now - cooldowns[user_id] < COOLDOWN_SECONDS:
        return
    cooldowns[user_id] = now

    channel_id = message.channel.id
    conversation_history.setdefault(channel_id, [])

    user_message = message.content.strip()
    if not user_message:
        return

    try:
        update_user_memory(message.author, user_message)

        reply = query_ai(
            user_message,
            conversation_history[channel_id],
            user_id
        )

        await message.channel.send(reply)

        conversation_history[channel_id].extend([
            {"role": "user", "content": user_message},
            {"role": "assistant", "content": reply}
        ])

    except Exception as e:
        await message.channel.send(f"❌ Error: {e}")

client.run(DISCORD_TOKEN)
