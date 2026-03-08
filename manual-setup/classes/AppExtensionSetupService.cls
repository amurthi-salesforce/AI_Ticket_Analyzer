/**
 * @description Service class to setup AI Ticket Analyzer App Extension in Field Service Mobile Settings.
 *              Separated from InstallHandler to support both package installation and CI/CD deployments.
 * @author AI Ticket Analyzer Package
 */
public inherited sharing class AppExtensionSetupService {

    /**
     * @description Adds AI Ticket Analyzer App Extension to provided Field Service Mobile Settings
     * @param targetSettings List of FieldServiceMobileSettings to configure
     */
    public static void setupAiAnalyzer(List<FieldServiceMobileSettings> targetSettings) {
        if (targetSettings == null || targetSettings.isEmpty()) {
            System.debug('No FieldServiceMobileSettings provided. Skipping App Extension installation.');
            return;
        }

        // Gather all the IDs
        Set<Id> settingIds = new Set<Id>();
        for (FieldServiceMobileSettings setting : targetSettings) {
            settingIds.add(setting.Id);
        }

        // BULKIFIED: Query all existing matching extensions at once (NO SOQL IN LOOPS)
        List<AppExtension> existingExts = [
            SELECT FieldServiceMobileSettingsId
            FROM AppExtension
            WHERE AppExtensionName = 'Analyze_Ticket_with_AI'
            AND FieldServiceMobileSettingsId IN :settingIds
        ];

        // Create a Set of Settings IDs that already have the extension
        Set<Id> settingsWithExtension = new Set<Id>();
        for (AppExtension ext : existingExts) {
            settingsWithExtension.add(ext.FieldServiceMobileSettingsId);
        }

        List<AppExtension> extensionsToInsert = new List<AppExtension>();

        // Loop through settings and only prepare extensions for those that need it
        for (FieldServiceMobileSettings setting : targetSettings) {
            if (!settingsWithExtension.contains(setting.Id)) {
                AppExtension newExt = new AppExtension(
                    AppExtensionLabel = 'Analyze Ticket with AI',
                    AppExtensionName = 'Analyze_Ticket_with_AI',
                    LaunchValue = 'c__aiTicketAnalyzer',
                    ScopedToObjectTypes = 'WorkOrder',
                    Type = 'LightningApp',
                    FieldServiceMobileSettingsId = setting.Id
                );
                extensionsToInsert.add(newExt);
            }
        }

        // Insert and handle results
        if (!extensionsToInsert.isEmpty()) {
            Database.SaveResult[] results = Database.insert(extensionsToInsert, false);
            Integer successCount = 0;
            Integer failureCount = 0;

            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    successCount++;
                } else {
                    failureCount++;
                    for (Database.Error err : sr.getErrors()) {
                        System.debug(LoggingLevel.ERROR, 'Failed to insert AppExtension: ' + err.getMessage());
                    }
                }
            }

            System.debug('Successfully installed ' + successCount + ' of ' + extensionsToInsert.size() + ' App Extension(s)');
            if (failureCount > 0) {
                System.debug(LoggingLevel.WARN, failureCount + ' App Extension(s) failed to install');
            }
        } else {
            System.debug('App Extension already exists in all provided Field Service Mobile Settings');
        }
    }
}
