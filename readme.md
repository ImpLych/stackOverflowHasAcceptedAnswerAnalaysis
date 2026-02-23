EN/TR
# Stack Overflow Accepted Answer Prediction 🤖💡

This project aims to predict whether a Stack Overflow question receives an **accepted answer** using machine learning techniques.

Instead of relying on textual data, the analysis focuses on **structural and behavioral features** of questions to understand what truly drives successful answers.

---

## 🎯 Objective

- Predict the likelihood of a question receiving an accepted answer  
- Identify impactful non-textual features  
- Compare rule-based and statistical learning approaches  

---

## 📊 Dataset

- **Source:** Kaggle  
- **Dataset:** Stack Overflow Programming Questions (2020–2025)  
- **Provider:** Kutay Ahin  

Textual fields such as *title*, *body*, and *tags* are intentionally excluded to reduce noise, prevent data leakage, and improve generalization.

---

## 🛠️ Methods & Tools

- Data cleaning and feature selection  
- Feature scaling (standardization)  
- Handling class imbalance using balanced metrics  
- **Models used:**
  - 🌳 C5.0 Decision Tree (rule-based, boosted)
  - 📈 Logistic Regression (baseline model)
- **Evaluation metrics:**
  - Accuracy
  - Kappa
  - Sensitivity
  - Specificity
  - Balanced Accuracy

---

## 🚀 Key Outcome

The **C5.0 model consistently outperforms Logistic Regression** across all balanced evaluation metrics, demonstrating that question-level metadata alone can be highly predictive of accepted answers.

---
---

# Stack Overflow Kabul Edilen Cevap Tahmini 🤖💡

Bu proje, makine ogrenmesi teknikleri kullanarak bir Stack Overflow sorusunun **kabul edilen cevap alip almayacagini** tahmin etmeyi amaclar.

Analiz, metinsel icerikler yerine sorularin **yapisal ve davranissal ozelliklerine** odaklanarak basarili cevaplari etkileyen faktorleri ortaya cikarmayi hedefler.

---

## 🎯 Amac

- Bir sorunun kabul edilen cevap alma olasiligini tahmin etmek  
- Metin disi ozelliklerin etkisini analiz etmek  
- Kural tabanli ve istatistiksel modelleri karsilastirmak  

---

## 📊 Veri Seti

- **Kaynak:** Kaggle  
- **Veri Seti:** Stack Overflow Programming Questions (2020–2025)  
- **Saglayan:** Kutay Ahin  

Baslik, govde ve etiket gibi metinsel alanlar; veri sizintisini onlemek ve model genellemesini artirmak amaciyla analiz disinda birakilmistir.

---

## 🛠️ Yontemler ve Araclar

- Veri temizleme ve ozellik secimi  
- Ozellik olceklendirme (standardizasyon)  
- Sinif dengesizligi icin dengeli metrikler  
- **Kullanilan modeller:**
  - 🌳 C5.0 Karar Agaci (kural tabanli, guclendirilmis)
  - 📈 Lojistik Regresyon (temel karsilastirma modeli)
- **Degerlendirme metrikleri:**
  - Accuracy (Dogruluk)
  - Kappa
  - Sensitivity
  - Specificity
  - Balanced Accuracy

---

## 🚀 Temel Sonuc

**C5.0 modeli**, tum dengeli performans metriklerinde Lojistik Regresyonu geride birakmistir.  
Bu sonuc, yalnizca soru seviyesindeki metaverilerin bile kabul edilen cevaplari tahmin etmede oldukca guclu oldugunu gostermektedir.
