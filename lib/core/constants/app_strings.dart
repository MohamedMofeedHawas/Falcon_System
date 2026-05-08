class AppStrings {
  // App Info
  static const String appName = 'نظام فالكون للتقييم الميداني';
  static const String systemTitle = 'FALCON-AIS';
  static const String subtitle = 'الكلية الجوية المصرية — قسم فحص المطارات';
  static const String version = '1.0.0';
  static const String optional = 'اختياري';
  static String get copyright =>
      '© ${DateTime.now().year} الكلية الجوية المصرية — جميع الحقوق محفوظة';
  static const String developer = 'تطوير: محمد مفيد حواس';

  // Splash Screen
  static const String loading = 'جاري التحميل...';

  // Admin Setup
  static const String adminSetup = 'إعداد ملف الأدمن';
  static const String personalPhoto = 'الصورة الشخصية';
  static const String basicInfo = 'البيانات الأساسية';
  static const String fullName = 'الاسم بالكامل';
  static const String email = 'البريد الإلكتروني';
  static const String nationality = 'الجنسية';
  static const String nationalId = 'الرقم العسكري';
  static const String rank = 'الرتبة';
  static const String age = 'العمر';
  static const String flightHours = 'عدد ساعات الطيران';
  static const String notAvailable = 'غير متاح';
  static const String contactInfo = 'بيانات التواصل';
  static const String phoneNumber = 'رقم الهاتف';
  static const String addPhone = 'إضافة رقم هاتف آخر';
  static const String workInfo = 'بيانات العمل';
  static const String governorate = 'المحافظة';
  static const String workplace = 'مكان العمل الحالي';
  static const String employmentDate = 'تاريخ التوظيف';
  static const String flyingLicense = 'رخصة الطيران';
  static const String haveLicense = 'هل تمتلك رخصة طيران؟';
  static const String licenseNumber = 'رقم الرخصة';
  static const String issueDate = 'تاريخ الحصول عليها';
  static const String expiryDate = 'تاريخ الانتهاء';
  static const String licenseValidity = 'مدة صلاحية الرخصة';
  static const String from = 'من';
  static const String to = 'إلى';
  static const String years = 'سنة';
  static const String months = 'شهر';
  static const String days = 'يوم';
  static const String valid = 'سارية';
  static const String expired = 'منتهية';
  static const String save = 'حفظ';
  static const String savedSuccessfully = 'تم حفظ بياناتك بنجاح ✓';

  // Login Screen
  static const String login = 'تسجيل الدخول';
  static const String username = 'اسم المستخدم';
  static const String password = 'كلمة المرور';
  static const String confirmPassword = 'تأكيد كلمة المرور';
  static const String dontHaveAccount = 'ليس لديك حساب؟';
  static const String createAccount = 'إنشاء حساب';
  static const String signIn = 'دخول';
  static const String loginSuccess = 'تم تسجيل الدخول بنجاح ✓';
  static const String invalidCredentials = 'بيانات دخول غير صحيحة';

  // Admin Setup Additional
  static const String registrationData = 'بيانات التسجيل';
  static const String whatsappNumbers = 'أرقام الواتس';
  static const String residenceAddress = 'عنوان الإقامة الحالي';
  static const String customNationality = 'أدخل الجنسية';
  static const String remainingValidity = 'المدة المتبقية';
  static const String licenseValidityError =
      'تاريخ الانتهاء يجب أن يكون بعد تاريخ البداية';

  // Nationalities
  static const List<String> nationalities = [
    'مصري',
    'سعودي',
    'إماراتي',
    'أردني',
    'كويتي',
    'أخرى',
  ];

  // Ranks
  static const List<String> ranks = [
    'طيار أول',
    'ملازم',
    'نقيب',
    'رائد',
    'مقدم',
    'عقيد',
    'عميد',
    'لواء',
    'فريق',
    'مشير',
  ];

  // Egyptian Governorates
  static const List<String> governorates = [
    'القاهرة',
    'الجيزة',
    'الإسكندرية',
    'الدقهلية',
    'الشرقية',
    'المنوفية',
    'القليوبية',
    'الغربية',
    'البحيرة',
    'الإسماعيلية',
    'الجيزة',
    'أسيوط',
    'سوهاج',
    'قنا',
    'الأقصر',
    'أسوان',
    'بورسعيد',
    'الإسماعيلية',
    'دمياط',
    'كفر الشيخ',
    'الفيوم',
    'بني سويف',
    'المنيا',
    'مطروح',
    'شمال سيناء',
    'جنوب سيناء',
    'البحر الأحمر',
    'الوادي الجديد',
  ];

  // Dashboard
  static const String dashboard = 'لوحة التحكم';
  static const String welcome = 'أهلاً،';
  static const String overview = 'نظرة عامة على المنظومة';
  static const String airForceSystem = 'Air Force Evaluation System';
  static const String live = 'مباشر';
  static const String totalAirports = 'إجمالي المطارات';
  static const String evaluatedAirports = 'المطارات المقيمة';
  static const String pendingEvaluation = 'بانتظار التقييم';
  static const String airportManagers = 'مديرو المطارات';
  static const String inspectionTeam = 'أعضاء لجنة الفحص والتفتيش';
  static const String registeredAircraft = 'الطائرات المسجلة';
  static const String averageScore = 'متوسط التقييم الكلي';
  static const String needsCorrection = 'مطارات تحتاج تصحيح';
  static const String unsafeAirports = 'مطارات غير آمنة';
  static const String recentEvaluations = 'آخر التقييمات';
  static const String airportName = 'اسم المطار';
  static const String evaluationDate = 'تاريخ التقييم';
  static const String score = 'الدرجة';
  static const String status = 'الحالة';
  static const String action = 'إجراء';
  static const String viewReport = 'عرض التقرير';
  static const String quickActions = 'إجراءات سريعة';
  static const String newAirport = '+ مطار جديد';
  static const String newEvaluationBtn = '+ تقييم جديد';
  static const String newMemberBtn = '+ عضو لجنة الفحص والتفتيش';
  static const String quickReport = '📄 تقرير سريع';
  static const String analytics = '📊 تحليل بياني';

  // Sidebar Navigation
  static const String home = 'لوحة التحكم';
  static const String airports = 'المطارات';
  static const String evaluations = 'التقييمات';
  static const String managers = 'مديرو المطارات';
  static const String team = 'لجنة الفحص والتفتيش';
  static const String aircraft = 'الطائرات';
  static const String reports = 'التقارير';
  static const String profile = 'الملف الشخصي';
  static const String help = 'المساعدة';

  // Aerodrome
  static const String aerodrome = 'المطار';
  static const String aerodromes = 'المطارات';
  static const String newAerodrome = 'مطار جديد';
  static const String editAerodrome = 'تعديل المطار';
  static const String deleteAerodrome = 'حذف المطار';
  static const String icaoCode = 'رمز المطار ICAO';
  static const String arabicName = 'اسم المطار بالعربية';
  static const String englishName = 'اسم المطار بالإنجليزية';
  static const String creationDate = 'تاريخ إنشاء المطار';
  static const String airportType = 'نوع المطار';
  static const String location = 'الموقع / المحافظة';
  static const String city = 'المدينة / المنطقة';
  static const String coordinates = 'خطوط الطول والعرض';
  static const String elevation = 'الارتفاع عن سطح البحر (متر)';
  static const String operationalStatus = 'حالة التشغيل';
  static const String detailedInfo = 'البيانات التفصيلية';
  static const String registrationNumber = 'رقم التسجيل الرسمي';
  static const String operator = 'الجهة المشغلة';
  static const String supervisingAuthority = 'سلطة الطيران المشرفة';
  static const String icaoCategory = 'فئة ICAO';
  static const String longestRunway = 'طول أطول مدرج (متر)';
  static const String capacity = 'الطاقة الاستيعابية (رحلة يومياً)';
  static const String notes = 'ملاحظات عامة';
  static const String lastInspection = 'تاريخ آخر تفتيش رسمي';
  static const String nextInspection = 'تاريخ التفتيش القادم';
  static const String runways = 'مدارج المطار';
  static const String runwayCount = 'عدد المدارج';
  static const String runwayName = 'اسم المدرج رقم';
  static const String airportManager = 'قائد المطار';
  static const String aerodromeSaved = 'تم حفظ بيانات المطار ✓';

  // Airport Types
  static const List<String> airportTypes = [
    'مطار دولي',
    'مطار داخلي',
    'قاعدة جوية',
    'مطار خاص',
    'ميدان طيران',
  ];

  // Operational Status
  static const List<String> operationalStatuses = [
    'نشط',
    'مغلق مؤقتاً',
    'تحت الصيانة',
    'قيد الإنشاء',
  ];

  // Supervising Authorities
  static const List<String> supervisingAuthorities = [
    'ECAA',
    'ICAO',
    'Local Authority',
  ];

  // Evaluation
  static const String evaluation = 'التقييم';
  static const String newEvaluation = 'تقييم جديد';
  static const String selectAirport = 'اختر المطار';
  static const String selectRunway = 'اختر المدرج';
  static const String inspectionDate = 'تاريخ الفحص';
  static const String teamMembers = ' أعضاء لجنة الفحص والتفتيش';
  static const String evaluationReport = 'تقرير التقييم';
  static const String finalReport = 'التقرير النهائي';
  static const String exportPDF = 'حفظ وتصدير PDF';
  static const String printReport = 'طباعة مباشرة';
  static const String savingFile = 'جاري حفظ الملف ...';
  static const String fileSaved = '✅ تم حفظ الملف على سطح المكتب بنجاح';

  // Evaluation Sections
  static const String runway = 'المدرج';
  static const String taxiway = 'ممرات التاكسي';
  static const String apron = 'ساحة الوقوف';
  static const String rffs = 'الإطفاء والإنقاذ';
  static const String met = 'الأرصاد الجوية';
  static const String navaids = 'مساعدات الملاحة';
  static const String operational = 'الإجراءات التشغيلية';
  static const String sms = 'نظام إدارة السلامة';
  static const String documents = 'الوثائق والتصاريح';

  // Evaluation Elements - Runway (12)
  static const String runwayLength = 'طول المدرج';
  static const String runwayWidth = 'عرض المدرج';
  static const String surfaceCondition = 'حالة السطح';
  static const String resa = 'منطقة أمان نهاية المدرج RESA';
  static const String markings = 'العلامات الأرضية Markings';
  static const String runwayLighting = 'إضاءة المدرج';
  static const String ofz = 'مناطق خلو العوائق OFZ';
  static const String pcn = 'قدرة تحمل المدرج PCN';
  static const String drainage = 'نظام الصرف Drainage';
  static const String signs = 'اللافتات Signs';
  static const String fuelDrainage = 'نظام تصريف الوقود الطارئ';
  static const String edgesShoulders = 'حالة الحواف والكتف Edges & Shoulders';

  // Evaluation Elements - Taxiway (7)
  static const String taxiwayWidth = 'العرض والمسافات الجانبية';
  static const String taxiwayMarkings = 'العلامات الأرضية';
  static const String taxiwayLighting = 'الإضاءة';
  static const String taxiwaySurface = 'حالة السطح';
  static const String taxiwaySigns = 'اللافتات الإرشادية';
  static const String stripClearway = 'مناطق العزل الجانبي Strip & Clearway';
  static const String taxiwayDrainage = 'الصرف Drainage';

  // Evaluation Elements - Apron (8)
  static const String parkingOrganization = 'تنظيم المواقف';
  static const String movementSafety = 'سلامة الحركة';
  static const String guidanceEquipment = 'معدات الإرشاد والتوجيه';
  static const String apronLighting = 'إنارة ساحة الوقوف';
  static const String apronSurface = 'حالة سطح ساحة الوقوف';
  static const String supportFacilities = 'مرافق دعم الطائرة';
  static const String apronDrainage = 'تصريف المياه في الساحة';
  static const String conflictPoints = 'عدم تداخل المسارات Conflict Points';

  // Evaluation Elements - RFFS (7)
  static const String rffsCategory = 'الفئة ICAO Category';
  static const String fireVehicles = 'مركبات الإطفاء';
  static const String fireMaterials = 'مواد الإطفاء';
  static const String crewReadiness = 'جاهزية الطواقم';
  static const String responseTime = 'زمن الاستجابة Response Time';
  static const String communications = 'نظام الاتصالات';
  static const String training = 'التدريبات والتنسيق';

  // Evaluation Elements - MET (6)
  static const String weatherReports = 'توفر التقارير الجوية';
  static const String basicEquipment = 'معدات القياس الأساسية';
  static const String advancedEquipment = 'معدات متقدمة حسب الحاجة';
  static const String informationTransfer = 'نقل المعلومات للمستخدمين';
  static const String maintenanceCalibration = 'صيانة ومعايرة المعدات';
  static const String aviationForecasts = 'الأرصاد للطيران/التوقعات';

  // Evaluation Elements - NAVAIDs (6)
  static const String papiVasi = 'نظام PAPI/VASI';
  static const String vor = 'جهاز VOR';
  static const String dme = 'نظام DME';
  static const String ils = 'نظام ILS إن وجد';
  static const String atisVolmet = 'خدمات المعلومات ATIS/VOLMET';
  static const String flightInspection = 'فحوصات الطيران Flight Inspection';

  // Evaluation Elements - Operational (6)
  static const String groundMovementPlan = 'خطة إدارة الحركة الأرضية';
  static const String aircraftMovement = 'تنظيم حركة الطائرات';
  static const String vehicleMovement = 'تنظيم حركة المركبات';
  static const String emergencyPlan = 'خطة الطوارئ AEP';
  static const String emergencyTraining = 'تدريبات الطوارئ الدورية';
  static const String wildlifeManagement = 'إدارة الحياة البرية Wildlife';

  // Evaluation Elements - SMS (5)
  static const String safetyPolicy = 'سياسة السلامة';
  static const String riskAssessment = 'تقييم المخاطر Risk Assessment';
  static const String reportingSystem = 'نظام الإبالغ Reporting System';
  static const String performanceReview = 'مراجعة الأداء Safety Performance';
  static const String smsTraining = 'التدريب على SMS';

  // Evaluation Elements - Documents (3)
  static const String aerodromeManual = 'وجود دليل Aerodrome Manual';
  static const String regularUpdates = 'تحديثات منتظمة';
  static const String permitsValidity = 'صلاحية التصاريح والرخص';

  // Evaluation UI
  static const String subElements = 'العناصر الفرعية';
  static const String evaluationScore = 'التقييم';
  static const String inspectorNote = 'ملاحظة المفتش';
  static const String warning = 'تنبيه';
  static const String sectionSummary = 'ملخص التقييم';
  static const String points = 'نقطة';
  static const String percentage = 'النسبة';
  static const String classification = 'التصنيف';
  static const String excellent = 'ممتاز';
  static const String good = 'جيد';
  static const String acceptable = 'مقبول';
  static const String unsafe = 'غير آمن';
  static const String criticalWarning =
      'تحذير: وجود عنصر حرج بتقييم صفر يستدعي إغلاق فورياً';

  // Final Decision
  static const String finalScore = 'الدرجة النهائية';
  static const String finalDecision = 'القرار النهائي';
  static const String operationalDecision = 'صالح للتشغيل — حالة ممتازة';
  static const String needsCorrectionDecision = 'يحتاج تصحيح — صالح مع ملاحظات';
  static const String notOperational = 'غير صالح — يوصى بإغلاق المطار';
  static const String criticalElements = 'البنود الحرجة';
  static const String requiredCorrections = 'التصحيحات المطلوبة';
  static const String recommendations = 'التوصيات';
  static const String reinspectionDeadline = 'مهلة إعادة الفحص';
  static const String reinspectionDate = 'تاريخ إعادة الفحص';

  // Airport Manager
  static const String manager = 'قائد المطار';
  static const String managersList = 'مديرو المطارات';
  static const String newManager = 'قائد جديد';
  static const String editManager = 'تعديل القائد';
  static const String deleteManager = 'حذف القائد';
  static const String employeeNumber = 'الرقم الوظيفي';
  static const String appointmentDate = 'تاريخ التعيين';
  static const String signature = 'التوقيع';
  static const String clearSignature = 'امسح';
  static const String saveSignature = 'حفظ التوقيع';
  static const String officialStamp = 'الختم الرسمي';
  static const String uploadStamp = 'رفع الختم';
  static const String stampNote = 'يُستخدم في التقارير الرسمية';
  static const String managerSaved = 'تم حفظ بيانات المدير ✓';

  // Inspection Team
  static const String inspectionHead = 'رئيس لجنة التفتيش';
  static const String inspectionMembers = 'أعضاء لجنة التفتيش';
  static const String newMember = 'عضو جديد';
  static const String editMember = 'تعديل العضو';
  static const String deleteMember = 'حذف العضو';
  static const String specialization = 'التخصص';
  static const String certificates = 'الشهادات';
  static const String yearsExperience = 'سنوات الخبرة';
  static const String joinDate = 'تاريخ الانضمام';
  static const String currentWorkplace = 'مكان العمل الحالي';
  static const String memberSaved = 'تم حفظ بيانات العضو ✓';

  // Specializations
  static const List<String> specializations = [
    'مدرجات وأسطح',
    'أنظمة إضاءة',
    'أجهزة ملاحة',
    'خدمات إطفاء',
    'أرصاد جوية',
    'إجراءات تشغيلية',
    'نظام SMS',
    'وثائق وتراخيص',
  ];

  // Aircraft
  static const String aircraftItem = 'الطائرة';
  static const String aircrafts = 'الطائرات';
  static const String newAircraft = 'طائرة جديدة';
  static const String editAircraft = 'تعديل الطائرة';
  static const String deleteAircraft = 'حذف الطائرة';
  static const String registration = 'رقم التسجيل';
  static const String aircraftType = 'الطراز';
  static const String manufacturer = 'الشركة الصانعة';
  static const String operatorName = 'المشغل';
  static const String serialNumber = 'الرقم التسلسلي';
  static const String manufacturingYear = 'سنة التصنيع';
  static const String operationStartDate = 'تاريخ بدء التشغيل';
  static const String lastMaintenance = 'تاريخ آخر صيانة';
  static const String maintenanceType = 'نوع الصيانة';
  static const String nextMaintenance = 'تاريخ الصيانة القادم';
  static const String totalFlightHours = 'إجمالي ساعات الطيران';
  static const String totalCycles = 'إجمالي الدورات';
  static const String aircraftStatus = 'الحالة';
  static const String engineType = 'نوع المحرك';
  static const String engineCount = 'عدد المحركات';
  static const String seatingCapacity = 'سعة المقاعد';
  static const String maxTakeoffWeight = 'الوزن الأقصى للإقلاع MTOW';
  static const String icaoCategoryAircraft = 'فئة ICAO';
  static const String aircraftPhoto = 'صورة الطائرة';
  static const String aircraftSaved = 'تم حفظ بيانات الطائرة ✓';
  static const String details = 'تفاصيل';
  static const String maintenanceDue = 'تستحق صيانة قريباً';
  static const String maintenanceUrgent = 'صيانة عاجلة';

  // Aircraft Status
  static const List<String> aircraftStatuses = [
    'نشطة',
    'في الصيانة',
    'خارج الخدمة',
    'مقاعدة',
    'مسحوبة',
  ];

  // Maintenance Types
  static const List<String> maintenanceTypes = [
    'A-Check',
    'B-Check',
    'C-Check',
    'D-Check',
  ];

  // Delete Verification
  static const String confirmDelete = 'تأكيد الحذف النهائي';
  static const String deleteWarning = 'أنت على وشك حذف';
  static const String willBeDeleted = 'سيتم حذف:';
  static const String cannotUndo = '⚠ هذا الإجراء لا يمكن التراجع عنه';
  static const String typeToConfirm = 'للتأكيد، اكتب';
  static const String below = 'أدناه';
  static const String cancel = 'إلغاء';
  static const String deletePermanently = 'حذف نهائياً';
  static const String deletedSuccessfully = 'تم الحذف بنجاح';

  // Profile
  static const String profileScreen = 'الملف الشخصي';
  static const String editProfile = 'تعديل الملف';
  static const String exportProfile = 'تصدير ملف البيانات الشخصية';
  static const String savingProfile = 'جاري حفظ ملف البيانات الشخصية...';
  static const String profileSaved = 'تم حفظ ملف البيانات الشخصية بنجاح';

  // Help
  static const String technicalSupport = 'الدعم الفني والمساعدة';
  static const String systemDeveloper = 'مطور النظام';
  static const String contactSupport = 'للتواصل والدعم الفني';
  static const String call = 'اتصال';
  static const String whatsapp = 'واتساب';
  static const String openWhatsapp = 'فتح واتساب';
  static const String sendEmail = 'إرسال بريد إلكتروني';
  static const String systemInfo = 'معلومات النظام';
  static const String userGuide = 'دليل المستخدم السريع';
  static const String howToAddAirport = 'كيفية إضافة مطار جديد';
  static const String howToEvaluate = 'كيفية إجراء تقييم';
  static const String howToExportPDF = 'تصدير تقرير PDF';
  static const String howToManageTeam = 'إدارة لجنة الفحص والتفتيش';
  static const String howToManageAircraft = 'إدارة الطائرات';

  // Contact Info
  static const String developerName = 'محمد مفيد حواس';
  static const String developerPhone = '01060157100';
  static const String developerEmail = 'mohamedznuav999@gmail.com';
  static const String emailSubject = 'دعم فني - نظام فالكون';

  // Validation Messages
  static const String requiredField = 'هذا الحقل مطلوب';
  static const String invalidEmail = 'البريد الإلكتروني غير صحيح';
 // static const String invalidNationalId = 'الرقم القومي يجب أن يكون 14 رقم';
  static const String invalidPhone = 'رقم الهاتف يجب أن يبدأ بـ 0 ويكون 11 رقم';
  static const String invalidAge = 'العمر يجب أن يكون بين 18 و 80';
  static const String invalidIcao =
      'رمز ICAO يجب أن يكون 4 أحرف إنجليزية كبيرة';
  static const String icaoValid = '✅ صحيح';
  static const String icaoInvalid = '❌ يجب أن يكون 4 أحرف إنجليزية كبيرة';
  static const String icaoExample = 'مثال: HECA للقاهرة، HEGN للغردقة';
  static const String runwayNameInvalid = 'اسم المدرج غير صحيح (مثال: 05/23)';

  // Common
  static const String search = 'بحث';
  static const String filter = 'تصفية';
  static const String sort = 'ترتيب';
  static const String edit = 'تعديل';
  static const String delete = 'حذف';
  static const String add = 'إضافة';
  static const String saveChanges = 'حفظ التغييرات';
  static const String cancelOperation = 'إلغاء العملية';
  static const String confirm = 'تأكيد';
  static const String yes = 'نعم';
  static const String no = 'لا';
  static const String close = 'إغلاق';
  static const String back = 'رجوع';
  static const String next = 'التالي';
  static const String previous = 'السابق';
  static const String finish = 'إنهاء';
  static const String loadingData = 'جاري تحميل البيانات...';
  static const String noData = 'لا توجد بيانات';
  static const String noResults = 'لا توجد نتائج';
  static const String error = 'خطأ';
  static const String success = 'نجاح';
  static const String tryAgain = 'حاول مرة أخرى';
  static const String refresh = 'تحديث';
  static const String logout = 'تسجيل الخروج';
  static const String settings = 'الإعدادات';
  static const String language = 'اللغة';
  static const String theme = 'المظهر';
  static const String light = 'فاتح';
  static const String dark = 'داكن';

  // Days of Week (Arabic)
  static const String sunday = 'الأحد';
  static const String monday = 'الاثنين';
  static const String tuesday = 'الثلاثاء';
  static const String wednesday = 'الأربعاء';
  static const String thursday = 'الخميس';
  static const String friday = 'الجمعة';
  static const String saturday = 'السبت';

  // Months (Arabic)
  static const String january = 'يناير';
  static const String february = 'فبراير';
  static const String march = 'مارس';
  static const String april = 'أبريل';
  static const String may = 'مايو';
  static const String june = 'يونيو';
  static const String july = 'يوليو';
  static const String august = 'أغسطس';
  static const String september = 'سبتمبر';
  static const String october = 'أكتوبر';
  static const String november = 'نوفمبر';
  static const String december = 'ديسمبر';
}
