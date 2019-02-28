import 'angular-mocks';
import i18next from 'i18next';

describe('userPreferences component', () => {
    let $ctrl;

    beforeEach(inject($componentController => {
        $ctrl = $componentController('userPreferences', {
            loggedInPerson: {
                updatePreferences: jest.fn(),
                person: {
                    user: {
                        notification_settings: {
                            person_moved: false,
                            person_assigned: false,
                            weekly_digest: false,
                        },
                    },
                },
            },
        });
    }));

    describe('onChangeLanguage', () => {
        it("should change the user's language", () => {
            $ctrl.onChangeLanguage('es-419');

            expect(i18next.language).toEqual('es-419');
            expect($ctrl.loggedInPerson.updatePreferences).toHaveBeenCalledWith(
                {
                    language: 'es-419',
                },
            );
        });
    });

    describe('onChangeNotificationSettings', () => {
        it("should change the user's notification settings", () => {
            $ctrl.personMoved = true;
            $ctrl.onChangeNotificationSettings();

            expect($ctrl.loggedInPerson.updatePreferences).toHaveBeenCalledWith(
                {
                    notification_settings: {
                        person_moved: true,
                        person_assigned: false,
                        weekly_digest: false,
                    },
                },
            );
        });
    });
});
