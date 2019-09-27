// This test mirrors a datadog synthetic test(https://app.datadoghq.com/synthetics/details/u2s-kfb-d6j),
// any changes to theistest should be made to the datadog synthetic test as well
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
    const apiUrl = 'https://api-stage.missionhub.com/apis/v4';
    const theKeyUrl = 'https://thekey.me/cas';

    const executionRegex = /<input .*?name="execution".*?value="(.+?)".*?\/>/;

    cy.request(
        `${theKeyUrl}/login?response_type=token&scope=fullticket&client_id=8138475243408077361&redirect_uri=https%3A%2F%2Fstage.missionhub.com%2Fauth-web`,
    ).then(({ body }) => {
        const [_, execution] = executionRegex.exec(body) || [];

        cy.request({
            method: 'post',
            url: `${theKeyUrl}/login?response_type=token&scope=fullticket&client_id=8138475243408077361&redirect_uri=https%3A%2F%2Fstage.missionhub.com%2Fauth-web`,
            form: true,
            body: {
                execution,
                _eventId: 'submit',
                username: 'test@test.com',
                password: 'Test1234',
            },
        }).then(({ redirects: [redirect] }) => {
            const accessTokenRegex = /access_token=(.+?)&/;
            const [_, accessToken] = accessTokenRegex.exec(redirect) || [];
            cy.visit(
                `/auth-web#token_type=bearer&access_token=${accessToken}&scope=fullticket&expires_in=3599&thekey_guid=49E1F2F9-55CC-6C10-58FF-B9B46CA79579&thekey_username=test%40test.com`,
            );
        });
    });
});

describe('People Dashboard', () => {
    it('should load the people dashboard', () => {
        cy.login();
        cy.get('[href="/ministries/14665"]').should('be', 'Test Organization');
    });
});
