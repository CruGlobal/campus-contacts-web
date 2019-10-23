// This test mirrors a datadog synthetic test(https://app.datadoghq.com/synthetics/details/u2s-kfb-d6j)
// any changes to this test should be made to the datadog synthetic test as well.
describe('Starting the Application', () => {
    it('should load the application', () => {
        cy.visit('/sign-in');
    });
});

describe('Find the login button', () => {
    it('Should be able to find the login button', () => {
        cy.get('[cy-test-id="loginWithEmailButton"]').should(
            'have.attr',
            'ng-href',
        );
    });
});

describe('Href should link to the key', () => {
    it('Should have an href directing to the key for sign in', () => {
        cy.get('[cy-test-id="loginWithEmailButton"]')
            .should('have.attr', 'ng-href')
            .then(href => {
                const keyUrl = href;
                expect(keyUrl).to.contain(
                    'https://thekey.me/cas/login?response_type=token&scope=fullticket&client_id=',
                );
            });
    });
});

describe('People Dashboard', () => {
    it('should load the people dashboard', () => {
        cy.signIn();
        cy.get('[href="/ministries/14665"]').should('be', 'Test Organization');
    });
});
