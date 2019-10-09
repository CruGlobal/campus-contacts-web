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

Cypress.Commands.add('login', () => {
    const theKeyUrl = 'https://thekey.me/cas';
    const email = 'test@test.com';
    const password = 'Test1234';
    const clientID = '5484233800086936290';

    cy.request({
        method: 'post',
        url: `${theKeyUrl}/api/oauth/token?grant_type=password&username=${email}&password=${password}&client_id=${clientID}`,
        form: true,
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
    }).then(({ body: { access_token } }) => {
        cy.visit(
            `/auth-web#token_type=bearer&access_token=${access_token}&scope=fullticket&expires_in=3599&thekey_guid=49E1F2F9-55CC-6C10-58FF-B9B46CA79579&thekey_username=test%40test.com`,
        );
    });
});

describe('People Dashboard', () => {
    it('should load the people dashboard', () => {
        cy.login();
        cy.get('[href="/ministries/14665"]').should('be', 'Test Organization');
    });
});
