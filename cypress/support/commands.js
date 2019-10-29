// ***********************************************
// This example commands.js shows you how to
// create various custom commands and overwrite
// existing commands.
//
// For more comprehensive examples of custom
// commands please read more here:
// https://on.cypress.io/custom-commands
// ***********************************************
//
//
// -- This is a parent command --
// Cypress.Commands.add("login", (email, password) => { ... })
Cypress.Commands.add('signIn', () => {
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
//
// -- This is a child command --
// Cypress.Commands.add("drag", { prevSubject: 'element'}, (subject, options) => { ... })
//
//
// -- This is a dual command --
// Cypress.Commands.add("dismiss", { prevSubject: 'optional'}, (subject, options) => { ... })
//
//
// -- This is will overwrite an existing command --
// Cypress.Commands.overwrite("visit", (originalFn, url, options) => { ... })
