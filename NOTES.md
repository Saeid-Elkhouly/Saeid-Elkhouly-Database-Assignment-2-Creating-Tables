

## 1. Schemas and Tables

قسمت الـ database إلى 4 schemas علشان كل مجموعة tables تكون خاصة بجزء معين من السيستم:

- **Identity:** خاصة ببيانات الأشخاص والمستخدمين والموظفين والمدن.
- **Inventory:** خاصة بالمنتجات والمخازن والتصنيفات والصور.
- **Auctions:** خاصة بالمزادات والمزايدات والمتابعة.
- **Finance:** خاصة بالمحافظ والبيانات المالية.

الفكرة إن كل schema تجمع الـ tables اللي ليها علاقة بنفس الجزء من الـ business.

## 2. Relationships Mapping

عملت ERD يوضح الـ tables والـ relationships بينهم، وأنواع العلاقات وطريقة تمثيلها في الـ database.

كل تفاصيل الـ Mapping موجودة في الـ ERD .

## 3. Data Types

- **GUID for Members:** استخدمته علشان الـ Member ID يكون Unique ومش مجرد رقم متسلسل.
- **BIGINT for Bids:** لأن عدد الـ Bids ممكن يكون كبير، فـ BIGINT بيديني Range أكبر من INT.
- **FLOAT for GPS:** لأن إحداثيات الموقع ممكن تحتوي على كسور عشرية.
- **DECIMAL for Money:** لأن القيم المالية محتاجة دقة، ومش مناسب أستخدم FLOAT فيها.
- **DATETIMEOFFSET for Auctions:** علشان أخزن التاريخ والوقت ومعاهم الـ Time Zone Offset.

## 4. Why Circular Relationship Cannot Be Created Directly?

لأن كل جدول محتاج يعمل Foreign Key على الجدول التاني، لكن وقت إنشاء أول جدول الجدول التاني ممكن لسه ما يكونش موجود.

الحل: أنشئ الجدولين الأول، وبعد كده أضيف الـ Foreign Keys باستخدام `ALTER TABLE`.



## 6. Task 3 Errors and Fixes

### 3.6 — Warehouse Capacity

حصل Error أثناء تعديل نوع العمود بسبب الـ CHECK Constraint المرتبط بالعمود.

الحل:
- شلت الـ Constraint القديم.
- عدلت اسم العمود ونوعه.
- رجعت أضفت CHECK Constraint تاني علشان أتأكد إن القيمة أكبر من صفر وفي الحدود المطلوبة.

### 3.11 — Member Verification

حصل Error لما حاولت أحذف عمود `IsVerified`؛ لأن كان مرتبط بيه Default Constraint.

الحل:
- حذفت الـ Default Constraint الأول.
- أضفت العمود الجديد `VerifiedAt`.
- بعد كده حذفت عمود `IsVerified`.

**Expand–Backfill–Contract Pattern:**

ده Pattern بنستخدمه لما نغير شكل الـ Database من غير ما نكسر الاعتماد على الـ structure القديم:

- **Expand:** نضيف الـ new column الأول.
- **Backfill:** ننقل البيانات القديمة للـ new column لو ينفع.
- **Contract:** نحذف الـ old column بعد ما نخلص الاعتماد عليه.

في التاسك ده طبقت فكرة Expand قبل Contract، لكن Backfill مش مناسب هنا؛ لأن قيمة Yes/No القديمة مش بتحدد تاريخ التحقق.

## 7. Task 5 — LeetCode 238

Input:

`nums = [1, 2, 3, 4]`

**Prefix:**

`prefix = [1, 1, 2, 6]`

**Suffix:**

`suffix = [24, 12, 4, 1]`

**Final Answer:**

`answer = [24, 12, 8, 6]`

كل عنصر في الـ Answer بيساوي حاصل ضرب الـ Prefix والـ Suffix عند نفس الـ Index.

- **5.1:** استخدمت Prefix Array و Suffix Array، والـ Space Complexity هي O(n).
- **5.2:** استخدمت Output Array ومتغير واحد للـ Suffix بدل مصفوفتين إضافيتين، والـ Extra Space هي O(1).