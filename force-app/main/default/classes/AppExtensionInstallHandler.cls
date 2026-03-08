/**
 * @description Post-install script for AI Ticket Analyzer package.
 *              Automatically adds the aiTicketAnalyzer App Extension to subscriber's
 *              existing Field Service Mobile Settings on package installation.
 * @author AI Ticket Analyzer Package
 */
global class AppExtensionInstallHandler implements InstallHandler {

    global void onInstall(InstallContext context) {
        try {
            // 1. Find all Field Service Mobile Settings in the subscriber's org
            List<FieldServiceMobileSettings> existingSettings = [
                SELECT Id
                FROM FieldServiceMobileSettings
                LIMIT 50
            ];

            if (existingSettings.isEmpty()) {
                // If they don't have Field Service set up yet, exit gracefully
                System.debug('No FieldServiceMobileSettings found. Skipping App Extension installation.');
                return;
            }

            List<AppExtension> extensionsToInsert = new List<AppExtension>();

            // 2. Loop through the settings and add the extension
            for (FieldServiceMobileSettings setting : existingSettings) {

                // Check if it already exists to prevent duplicates on package upgrades
                Integer existingCount = [
                    SELECT COUNT()
                    FROM AppExtension
                    WHERE AppExtensionName = 'Analyze_Ticket_with_AI'
                    AND FieldServiceMobileSettingsId = :setting.Id
                ];

                if (existingCount == 0) {
                    AppExtension newExt = new AppExtension();
                    newExt.AppExtensionLabel = 'Analyze Ticket with AI';
                    newExt.AppExtensionName = 'Analyze_Ticket_with_AI';
                    newExt.LaunchValue = 'c__aiTicketAnalyzer';
                    newExt.ScopedToObjectTypes = 'WorkOrder';
                    newExt.Type = 'LightningApp';
                    newExt.FieldServiceMobileSettingsId = setting.Id;

                    extensionsToInsert.add(newExt);
                }
            }

            // 3. Insert the new extensions
            if (!extensionsToInsert.isEmpty()) {
                insert extensionsToInsert;
                System.debug('Successfully installed ' + extensionsToInsert.size() + ' App Extension(s)');
            } else {
                System.debug('App Extension already exists. No action needed.');
            }

        } catch (Exception e) {
            // Log error but don't block installation
            System.debug(LoggingLevel.ERROR, 'Error installing App Extension: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack Trace: ' + e.getStackTraceString());
        }
    }
}
