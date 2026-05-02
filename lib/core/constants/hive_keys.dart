class HiveKeys {
  // Box Names
  static const String adminProfileBox = 'admin_profile';
  static const String aerodromesBox = 'aerodromes';
  static const String airportManagersBox = 'airport_managers';
  static const String inspectionHeadBox = 'inspection_head';
  static const String inspectionTeamBox = 'inspection_team';
  static const String aircraftBox = 'aircraft';
  static const String evaluationReportsBox = 'evaluation_reports';

  // Admin Profile Keys
  static const String adminId = 'admin_id';
  static const String adminFullName = 'admin_full_name';
  static const String adminEmail = 'admin_email';
  static const String adminNationality = 'admin_nationality';
  static const String adminNationalId = 'admin_national_id';
  static const String adminRank = 'admin_rank';
  static const String adminAge = 'admin_age';
  static const String adminFlightHours = 'admin_flight_hours';
  static const String adminPhones = 'admin_phones';
  static const String adminGovernorate = 'admin_governorate';
  static const String adminWorkplace = 'admin_workplace';
  static const String adminEmploymentDate = 'admin_employment_date';
  static const String adminHasLicense = 'admin_has_license';
  static const String adminLicenseNumber = 'admin_license_number';
  static const String adminLicenseIssueDate = 'admin_license_issue_date';
  static const String adminLicenseExpiryDate = 'admin_license_expiry_date';
  static const String adminPhoto = 'admin_photo';

  // Aerodrome Keys
  static const String aerodromeId = 'aerodrome_id';
  static const String icaoCode = 'icao_code';
  static const String arabicName = 'arabic_name';
  static const String englishName = 'english_name';
  static const String creationDate = 'creation_date';
  static const String airportType = 'airport_type';
  static const String governorate = 'governorate';
  static const String city = 'city';
  static const String latitude = 'latitude';
  static const String longitude = 'longitude';
  static const String elevation = 'elevation';
  static const String operationalStatus = 'operational_status';
  static const String registrationNumber = 'registration_number';
  static const String operator = 'operator';
  static const String supervisingAuthority = 'supervising_authority';
  static const String icaoCategory = 'icao_category';
  static const String longestRunway = 'longest_runway';
  static const String capacity = 'capacity';
  static const String notes = 'notes';
  static const String lastInspection = 'last_inspection';
  static const String nextInspection = 'next_inspection';
  static const String runways = 'runways';
  static const String managerId = 'manager_id';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';

  // Airport Manager Keys
  static const String managerIdKey = 'manager_id';
  static const String aerodromeIdKey = 'aerodrome_id';
  static const String fullName = 'full_name';
  static const String rank = 'rank';
  static const String nationalId = 'national_id';
  static const String email = 'email';
  static const String phone = 'phone';
  static const String photo = 'photo';
  static const String signature = 'signature';
  static const String officialStamp = 'official_stamp';
  static const String employeeNumber = 'employee_number';
  static const String appointmentDate = 'appointment_date';
  static const String isEvaluated = 'is_evaluated';

  // Inspection Head Keys
  static const String headId = 'head_id';
  static const String qualifications = 'qualifications';
  static const String yearsExperience = 'years_experience';

  // Inspection Member Keys
  static const String memberId = 'member_id';
  static const String specialization = 'specialization';
  static const String certificates = 'certificates';
  static const String flightHours = 'flight_hours';
  static const String joinDate = 'join_date';
  static const String currentWorkplace = 'current_workplace';
  static const String memberNotes = 'member_notes';

  // Aircraft Keys
  static const String aircraftId = 'aircraft_id';
  static const String aerodromeIdAircraft = 'aerodrome_id';
  static const String aircraftRegistration = 'aircraft_registration';
  static const String aircraftType = 'aircraft_type';
  static const String manufacturer = 'manufacturer';
  static const String operatorName = 'operator_name';
  static const String serialNumber = 'serial_number';
  static const String manufacturingYear = 'manufacturing_year';
  static const String operationStartDate = 'operation_start_date';
  static const String lastMaintenanceDate = 'last_maintenance_date';
  static const String maintenanceType = 'maintenance_type';
  static const String nextMaintenanceDate = 'next_maintenance_date';
  static const String totalFlightHoursAircraft = 'total_flight_hours';
  static const String totalCycles = 'total_cycles';
  static const String aircraftStatus = 'aircraft_status';
  static const String engineType = 'engine_type';
  static const String engineCount = 'engine_count';
  static const String seatingCapacity = 'seating_capacity';
  static const String maxTakeoffWeight = 'max_takeoff_weight';
  static const String icaoCategoryAircraft = 'icao_category_aircraft';
  static const String aircraftPhoto = 'aircraft_photo';
  static const String aircraftNotes = 'aircraft_notes';

  // Evaluation Report Keys
  static const String reportId = 'report_id';
  static const String aerodromeIdReport = 'aerodrome_id';
  static const String runwayId = 'runway_id';
  static const String evaluationDateReport = 'evaluation_date';
  static const String teamMembersIds = 'team_members_ids';
  static const String reportNumber = 'report_number';
  static const String finalScore = 'final_score';
  static const String finalDecision = 'final_decision';
  static const String criticalElements = 'critical_elements';
  static const String requiredCorrections = 'required_corrections';
  static const String recommendations = 'recommendations';
  static const String reinspectionDeadline = 'reinspection_deadline';
  static const String reinspectionDate = 'reinspection_date';
  static const String managerSignature = 'manager_signature';
  static const String headSignature = 'head_signature';
  static const String reportCreatedAt = 'report_created_at';

  // Evaluation Section Keys
  static const String runwayEvaluation = 'runway_evaluation';
  static const String taxiwayEvaluation = 'taxiway_evaluation';
  static const String apronEvaluation = 'apron_evaluation';
  static const String rffsEvaluation = 'rffs_evaluation';
  static const String metEvaluation = 'met_evaluation';
  static const String navaidsEvaluation = 'navaids_evaluation';
  static const String operationalEvaluation = 'operational_evaluation';
  static const String smsEvaluation = 'sms_evaluation';
  static const String documentsEvaluation = 'documents_evaluation';

  // Section Score Keys
  static const String sectionScore = 'section_score';
  static const String sectionMaxScore = 'section_max_score';
  static const String sectionPercentage = 'section_percentage';
  static const String sectionClassification = 'section_classification';
  static const String elementScores = 'element_scores';
  static const String elementNotes = 'element_notes';

  // SharedPreferences Keys
  static const String isAdminSetupComplete = 'is_admin_setup_complete';
  static const String appVersion = 'app_version';
  static const String lastBackupDate = 'last_backup_date';
  static const String selectedTheme = 'selected_theme';
  static const String selectedLanguage = 'selected_language';
  static const String firstLaunch = 'first_launch';
  static const String lastEvaluationId = 'last_evaluation_id';

  // Type IDs for Hive Adapters
  static const int adminProfileTypeId = 0;
  static const int aerodromeTypeId = 1;
  static const int airportManagerTypeId = 2;
  static const int inspectionHeadTypeId = 3;
  static const int inspectionMemberTypeId = 4;
  static const int aircraftTypeId = 5;
  static const int evaluationReportTypeId = 6;
  static const int runwayEvaluationTypeId = 7;
  static const int taxiwayEvaluationTypeId = 8;
  static const int apronEvaluationTypeId = 9;
  static const int rffsEvaluationTypeId = 10;
  static const int metEvaluationTypeId = 11;
  static const int navaidsEvaluationTypeId = 12;
  static const int operationalEvaluationTypeId = 13;
  static const int smsEvaluationTypeId = 14;
  static const int documentsEvaluationTypeId = 15;
}
