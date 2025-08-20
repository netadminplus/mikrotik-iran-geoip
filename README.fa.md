# MikroTik Iran GeoIP

نصب و به‌روزرسانی خودکار لیست آدرس‌های IP ایران برای دستگاه‌های MikroTik RouterOS.

## ویژگی‌ها

- **نصب تک‌دستوری** - نصب کامل با یک دستور کپی-پیست
- **به‌روزرسانی هفتگی خودکار** - همیشه با آخرین محدوده‌های IP همگام
- **چندین منبع** - ترکیب داده‌ها از ipdeny، پارس‌پک و ابرآروان
- **شامل RFC1918** - اضافه کردن خودکار محدوده‌های IP خصوصی
- **ایمن و قابل تکرار** - می‌توان در هر زمان مجدداً اجرا کرد

## نصب سریع

این دو دستور را در ترمینال MikroTik خود کپی و اجرا کنید:

```bash
/tool fetch url="https://raw.githubusercontent.com/netadminplus/mikrotik-iran-geoip/main/installer.rsc" mode=https dst-path=installer.rsc
/import file-name=installer.rsc
```

همین! سیستم اقدامات زیر را انجام می‌دهد:
- لیست آدرس به نام `IRAN` ایجاد می‌کند
- تمام محدوده‌های IP ایران را وارد می‌کند
- محدوده‌های خصوصی RFC1918 را اضافه می‌کند (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16)
- به‌روزرسانی هفتگی خودکار را هر یکشنبه ساعت 03:00 تنظیم می‌کند

## پیش‌نیازها

- RouterOS نسخه 7+ (نسخه 6 ممکن است کار کند اما تست نشده)
- دسترسی اینترنت برای دانلود به‌روزرسانی‌ها
- زمان صحیح سیستم برای تأیید گواهی HTTPS

## عیب‌یابی

اگر خطای گواهی HTTPS به دلیل زمان نادرست سیستم دریافت کردید:

```bash
/tool fetch url="https://raw.githubusercontent.com/netadminplus/mikrotik-iran-geoip/main/installer.rsc" mode=https check-certificate=no dst-path=installer.rsc
/import file-name=installer.rsc
```

## مدیریت

**به‌روزرسانی دستی:**
```bash
/system script run update-iran-geoip
```

**غیرفعال کردن به‌روزرسانی خودکار:**
```bash
/system scheduler disable iran-geoip-weekly
```

**حذف کامل:**
```bash
/system scheduler remove iran-geoip-weekly
/system script remove update-iran-geoip
/ip firewall address-list remove [find list=IRAN]
```

## منابع داده

این پروژه محدوده‌های IP را از منابع زیر ترکیب می‌کند:
- [بلوک‌های کشور ایران IPdeny](https://www.ipdeny.com/ipblocks/data/countries/ir.zone)
- [IP های CDN پارس‌پک](https://parspack.com/cdnips.txt)
- [IP های ابرآروان](https://www.arvancloud.ir/fa/ips.txt)

آخرین به‌روزرسانی: <!--LAST_UPDATED-->هرگز<!--/LAST_UPDATED-->

## نمونه‌های استفاده

از لیست آدرس `IRAN` در قوانین فایروال خود استفاده کنید:

```bash
# مسدود کردن ترافیک ایران
/ip firewall filter add chain=forward src-address-list=IRAN action=drop

# اجازه دادن فقط به ترافیک ایران
/ip firewall filter add chain=forward src-address-list=!IRAN action=drop

# محدود کردن نرخ ترافیک ایران
/ip firewall mangle add chain=forward src-address-list=IRAN action=mark-connection new-connection-mark=iran-conn
```

## مجوز

مجوز MIT - برای جزئیات فایل [LICENSE](LICENSE) را ببینید.

## پیوندها

- [راهنمای انگلیسی](README.md) - English README
- [مسائل](../../issues) - گزارش مشکلات یا درخواست ویژگی
- [انتشارها](../../releases) - تاریخچه نسخه‌ها