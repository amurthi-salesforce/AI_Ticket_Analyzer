// ========================================================================
// AI Ticket Analyzer - FSL Mobile App Extension Setup
// ========================================================================
//
// IMPORTANT: This script must be run after package installation OR
// manual deployment to add the "Analyze Ticket with AI" App Extension
// to your Field Service Mobile Settings.
//
// WHY: Salesforce packaging restrictions prevent manipulating AppExtension
// and FieldServiceMobileSettings objects in post-install scripts.
//
// PREREQUISITES:
// 1. Deploy the AppExtensionSetupService class first:
//    sf project deploy start --source-dir manual-setup/classes --target-org your-org
//
// 2. Then run this script:
//    sf apex run -f scripts/apex/setupExtension.apex --target-org your-org
//
// ALTERNATIVE: Execute directly in Developer Console (after deploying classes):
//    List<FieldServiceMobileSettings> settings = [SELECT Id FROM FieldServiceMobileSettings LIMIT 50];
//    AppExtensionSetupService.setupAiAnalyzer(settings);
//
// ========================================================================

List<FieldServiceMobileSettings> settings = [SELECT Id FROM FieldServiceMobileSettings LIMIT 50];
AppExtensionSetupService.setupAiAnalyzer(settings);
System.debug('Setup complete! Check Field Service Mobile Settings for the new App Extension.');
