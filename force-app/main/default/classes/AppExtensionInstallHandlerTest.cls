/**
 * @description Test class for AppExtensionInstallHandler post-install script
 * @author AI Ticket Analyzer Package
 */
@isTest
private class AppExtensionInstallHandlerTest {

    @isTest
    static void testInstallScript_CreatesExtension() {
        // Insert a dummy Field Service Mobile Settings for the test
        FieldServiceMobileSettings testSetting = new FieldServiceMobileSettings(
            DeveloperName = 'Test_Settings',
            MasterLabel = 'Test Settings'
        );
        insert testSetting;

        Test.startTest();

        // Run the install handler
        AppExtensionInstallHandler handler = new AppExtensionInstallHandler();
        Test.testInstall(handler, null, true);

        Test.stopTest();

        // Verify the App Extension was created
        List<AppExtension> insertedExt = [
            SELECT Id, AppExtensionName, AppExtensionLabel, LaunchValue, Type
            FROM AppExtension
            WHERE FieldServiceMobileSettingsId = :testSetting.Id
        ];

        System.assertEquals(1, insertedExt.size(), 'The App Extension should have been inserted');
        System.assertEquals('Analyze_Ticket_with_AI', insertedExt[0].AppExtensionName, 'App Extension name should match');
        System.assertEquals('Analyze Ticket with AI', insertedExt[0].AppExtensionLabel, 'Label should match');
        System.assertEquals('c__aiTicketAnalyzer', insertedExt[0].LaunchValue, 'Launch value should match');
        System.assertEquals('LightningApp', insertedExt[0].Type, 'Type should be LightningApp');
    }

    @isTest
    static void testInstallScript_PreventsDuplicates() {
        // Insert a dummy Field Service Mobile Settings
        FieldServiceMobileSettings testSetting = new FieldServiceMobileSettings(
            DeveloperName = 'Test_Settings_Duplicate',
            MasterLabel = 'Test Settings Duplicate'
        );
        insert testSetting;

        // Manually insert an App Extension (simulating it already exists)
        AppExtension existingExt = new AppExtension();
        existingExt.AppExtensionLabel = 'Analyze Ticket with AI';
        existingExt.AppExtensionName = 'Analyze_Ticket_with_AI';
        existingExt.LaunchValue = 'c__aiTicketAnalyzer';
        existingExt.ScopedToObjectTypes = 'WorkOrder';
        existingExt.Type = 'LightningApp';
        existingExt.FieldServiceMobileSettingsId = testSetting.Id;
        insert existingExt;

        Test.startTest();

        // Run the install handler (should detect existing and skip)
        AppExtensionInstallHandler handler = new AppExtensionInstallHandler();
        Test.testInstall(handler, null, true);

        Test.stopTest();

        // Verify no duplicate was created
        List<AppExtension> extensions = [
            SELECT Id
            FROM AppExtension
            WHERE FieldServiceMobileSettingsId = :testSetting.Id
        ];

        System.assertEquals(1, extensions.size(), 'Should not create duplicate App Extension');
    }

    @isTest
    static void testInstallScript_NoSettingsExists() {
        // Don't create any FieldServiceMobileSettings

        Test.startTest();

        // Run the install handler (should handle gracefully)
        AppExtensionInstallHandler handler = new AppExtensionInstallHandler();
        Test.testInstall(handler, null, true);

        Test.stopTest();

        // Verify no App Extensions were created
        List<AppExtension> extensions = [SELECT Id FROM AppExtension];
        System.assertEquals(0, extensions.size(), 'Should not create App Extension when no settings exist');
    }

    @isTest
    static void testInstallScript_MultipleSettings() {
        // Insert multiple Field Service Mobile Settings
        List<FieldServiceMobileSettings> settings = new List<FieldServiceMobileSettings>{
            new FieldServiceMobileSettings(DeveloperName = 'Test_Settings_1', MasterLabel = 'Test 1'),
            new FieldServiceMobileSettings(DeveloperName = 'Test_Settings_2', MasterLabel = 'Test 2')
        };
        insert settings;

        Test.startTest();

        // Run the install handler
        AppExtensionInstallHandler handler = new AppExtensionInstallHandler();
        Test.testInstall(handler, null, true);

        Test.stopTest();

        // Verify App Extensions were created for all settings
        List<AppExtension> extensions = [SELECT Id, FieldServiceMobileSettingsId FROM AppExtension];
        System.assertEquals(2, extensions.size(), 'Should create App Extension for each setting');
    }
}
