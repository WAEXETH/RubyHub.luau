<div align="center">

# 💎 RubyHub.luau

**คลังสคริปต์ Roblox (Lua/Luau) ที่เขียนเล่นสนุก ๆ ใช้งานง่าย แค่คัดลอกแล้วรัน**

![Language](https://img.shields.io/badge/Language-Lua-2C2D72?style=for-the-badge&logo=lua&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Roblox-E2231A?style=for-the-badge&logo=roblox&logoColor=white)
![Commits](https://img.shields.io/github/commit-activity/t/WAEXETH/RubyHub.luau?style=for-the-badge)
![Last Commit](https://img.shields.io/github/last-commit/WAEXETH/RubyHub.luau?style=for-the-badge)

*"This is just my writing for fun, nothing much. I do it for fun, I don't expect anything in return."*

</div>

---

## 📚 สารบัญ

- [🎮 รายการสคริปต์](#-รายการสคริปต์)
- [💻 วิธีติดตั้งและใช้งาน](#-วิธีติดตั้งและใช้งาน-how-to-execute)
- [🧰 Executor ที่รองรับ](#-executor-ที่รองรับ)
- [❓ ปัญหาที่พบบ่อย](#-ปัญหาที่พบบ่อย)
- [⚠️ ข้อควรระวัง](#️-ข้อควรระวัง)
- [🤝 ติดต่อและสนับสนุน](#-ติดต่อและสนับสนุน)

---

## 🎮 รายการสคริปต์

| สคริปต์ | ไฟล์ | สถานะ |
|:--|:--|:--:|
| 🔹 AUT | [`AUT.lua`](./AUT.lua) | ✅ |
| 🗡️ Cursed Blade | [`CursedBlade[ALPHA].lua`](./CursedBlade[ALPHA].lua) | 🧪 Alpha |
| 👁️ ESP CTS | [`ESPCTS.lua`](./ESPCTS.lua) | ✅ |
| 🍞 Feed Your Teto | [`FeedYourTeto.lua`](./FeedYourTeto.lua) | ✅ |
| 🏃 Last Run | [`LastRun.lua`](./LastRun.lua) | ✅ |
| 🔹 MTC | [`MTC.lua`](./MTC.lua) | ✅ |
| 🥷 Ninja Legends | [`NinjaLegendsby.lua`](./NinjaLegendsby.lua) | ✅ |
| 🏍️ Rider World | [`RiderWorld.lua`](./RiderWorld.lua) | ✅ |
| 🌸 Sakura Stand | [`SakuraStand.lua`](./SakuraStand.lua) | ✅ |

> 💡 สคริปต์ต้อง **ตรงกับเกม** ที่คุณกำลังเล่นอยู่ จึงจะใช้งานได้

---

## 💻 วิธีติดตั้งและใช้งาน (How to Execute)

1. 🎯 **เปิดเกม Roblox** ที่ต้องการเล่น (ต้องตรงกับสคริปต์ที่ใช้)
2. ⚙️ **เปิด Executor** ของคุณ
3. 📋 **คัดลอกโค้ดรันเนอร์** ด้านล่าง ไปวางใน Executor แล้วกดปุ่ม `Execute`

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/WAEXETH/RubyHub.luau/main/ชื่อไฟล์.lua"))()
```

> เปลี่ยน `ชื่อไฟล์.lua` เป็นสคริปต์ที่ต้องการ เช่น `SakuraStand.lua`

### ตัวอย่าง

```lua
-- Sakura Stand
loadstring(game:HttpGet("https://raw.githubusercontent.com/WAEXETH/RubyHub.luau/main/SakuraStand.lua"))()
```

---

## 🧰 Executor ที่รองรับ

| Executor | รองรับ |
|:--|:--:|
| Potassium | ✅ |
| Madium | ✅ |
| Wave | ✅ |
| Volt | ✅ |
| อื่น ๆ | ✅ รองรับ `loadstring` และ `HttpGet` |

---

## ❓ ปัญหาที่พบบ่อย

<details>
<summary><b>สคริปต์ไม่ทำงาน / ไม่มีอะไรเกิดขึ้น</b></summary>

- ตรวจสอบว่าเปิดเกมที่ **ตรงกับสคริปต์** แล้ว
- รอให้เกมโหลดเสร็จก่อนกด Execute
- ลองอัปเดต Executor เป็นเวอร์ชันล่าสุด

</details>

<details>
<summary><b>ขึ้น error เกี่ยวกับ HttpGet / loadstring</b></summary>

Executor ของคุณอาจไม่รองรับฟังก์ชันนี้ ลองเปลี่ยนไปใช้ Executor ตัวอื่นในตารางด้านบน

</details>

<details>
<summary><b>เกมอัปเดตแล้วสคริปต์พัง</b></summary>

เปิด [Issues](../../issues) แจ้งชื่อสคริปต์และข้อความ error ได้เลย

</details>

---

## ⚠️ ข้อควรระวัง

- โปรเจกต์นี้ทำขึ้น **เพื่อความสนุกและการเรียนรู้** เท่านั้น
- การใช้สคริปต์ในเกมอาจขัดกับข้อกำหนดของ Roblox และเกมนั้น ๆ และอาจทำให้บัญชีถูกลงโทษได้ **ใช้ด้วยความเสี่ยงของตัวเอง**
- แนะนำให้ทดลองกับ **บัญชีรอง** เสมอ

---

## 🤝 ติดต่อและสนับสนุน

- 🐛 พบบั๊ก หรืออยากเสนอไอเดีย → เปิด [Issue](../../issues)
- ⭐ ถ้าชอบโปรเจกต์นี้ ฝากกดดาวให้ด้วยนะ
- 👤 ผู้พัฒนา: [**WAEXETH**](https://github.com/WAEXETH)

<div align="center">

Made with 💖 by WAEXETH

</div>
