import 'package:flutter/material.dart';
import 'email_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool accepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurple.shade900, Colors.black87],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 20),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.red.shade400, Colors.red.shade700],
                        ),
                      ),
                      child: const Icon(
                        Icons.play_circle_fill,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'VoiPlay Tv',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Eng yaxshi anime platformasi',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha((0.05 * 255).round()),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withAlpha((0.1 * 255).round()),
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MAXFIYLIK SIYOSATI',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 15),
                          Text(
                            'VoiPlay TV sizning shaxsiy ma\'lumotlaringizni himoya qiladi. Biz faqat ilovani yaxshi ishlashi uchun zarur ma\'lumotlarni to\'playmiz.\n\n'
                            'Quyidagi ma\'lumotlar to\'planadi:\n'
                            '• Email manzil va parol\n'
                            '• Ko\'rgan tarixingiz\n'
                            '• Saqlangan anime ro\'yhati\n'
                            '• Profil rasmingiz\n\n'
                            'Ma\'lumotlaringiz uchinchi tomonlarla ulashilmaydi. Faqat VoiPlay API orqali xizmat ko\'rsatishda foydalaniladi.\n\n'
                            'Reklamalar mavjud bo\'lishi mumkin, lekin hech qandey shaxsiy ma\'lumot reklamachilarla ulashilmaydi.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: accepted,
                          onChanged: (v) =>
                              setState(() => accepted = v ?? false),
                          activeColor: Colors.red.shade400,
                        ),
                        const Expanded(
                          child: Text(
                            'Maxfiylik siyosati va sharti bilan rozimanman',
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: accepted
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const EmailScreen(),
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          disabledBackgroundColor: Colors.grey.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Davom etish',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
