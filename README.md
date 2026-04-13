# jagawarung

A new Flutter project.

Alur Kerja GitHub untuk 2 Developer (Git Flow Sederhana)
Karena kalian hanya berdua, jangan gunakan alur Git yang terlalu rumit. Gunakan pendekatan Feature Branching:

Branch main / master: Ini adalah branch suci. Kodenya harus selalu bisa di-run (tidak error). Jangan pernah coding langsung di sini.

Branch dev (Opsional tapi disarankan): Tempat berkumpulnya fitur-fitur yang sudah selesai sebelum digabung ke main.

Branch Fitur (feature/nama-fitur): Saat kamu (Dev 1) atau temanmu (Dev 2) mau mengerjakan sesuatu, buat branch baru dari main.

Contoh Dev 1: git checkout -b feature/ui-login

Contoh Dev 2: git checkout -b feature/logic-kasir

Pull Request (PR) & Code Review: Jika Dev 1 sudah selesai, jangan langsung di-merge. Buat Pull Request di GitHub. Dev 2 wajib melihat kode Dev 1, lalu klik Approve jika sudah aman. Baru setelah itu di-merge ke branch utama. Ini memastikan kalian saling tahu apa yang dikerjakan satu sama lain.
