/**
 * @description Post-install script for AI Ticket Analyzer package.
 *              Automatically adds the aiTicketAnalyzer App Extension to subscriber's
 *              existing Field Service Mobile Settings on package installation.
 * @author AI Ticket Analyzer Package
 */
global class AppExtensionInstallHandler implements InstallHandler {

    global void onInstall(InstallContext context) {
        try {
            // Query all Field Service Mobile Settings
            List<FieldServiceMobileSettings> existingSettings = [
                SELECT Id
                FROM FieldServiceMobileSettings
                LIMIT 50
            ];

            // Call the service class to setup the extension
            AppExtensionSetupService.setupAiAnalyzer(existingSettings);

        } catch (Exception e) {
            // Log error but don't block installation
            System.debug(LoggingLevel.ERROR, 'Error in InstallHandler: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack Trace: ' + e.getStackTraceString());
        }
    }
}

