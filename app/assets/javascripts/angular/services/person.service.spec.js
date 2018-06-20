import 'angular-mocks';

// Constants
var personService, $rootScope, httpProxy;

function asynchronous(fn) {
    return function(done) {
        var returnValue = fn.call(this, done);
        returnValue
            .then(function() {
                done();
            })
            .catch(function(err) {
                done.fail(err);
            });
        $rootScope.$apply();
        return returnValue;
    };
}

describe('personService', function() {
    beforeEach(angular.mock.module('missionhubApp'));

    beforeEach(inject(function(_personService_, _$rootScope_, $q, _httpProxy_) {
        personService = _personService_;
        $rootScope = _$rootScope_;
        httpProxy = _httpProxy_;

        this.organizationalPermission = {
            id: 21,
            organization_id: 1,
            organization: {
                people: [{ id: 11 }, { id: 12 }],
            },
        };
        this.person = {
            _type: 'person',
            id: 11,
            organizational_permissions: [
                this.organizationalPermission,
                { id: 22, organization_id: 2 },
                { id: 23, organization_id: 3 },
            ],
            reverse_contact_assignments: [
                {
                    organization: { id: 1 },
                    assigned_to: { name: 'Adam' },
                    created_at: '2',
                },
                {
                    organization: { id: 1 },
                    assigned_to: { name: 'Alice' },
                    created_at: '1',
                },
                {
                    organization: { id: 2 },
                    assigned_to: { name: 'Bill' },
                },
                {
                    organization: { id: 3 },
                    assigned_to: { name: 'Charles' },
                },
            ],
            phone_numbers: [
                { number: '000000000', primary: false },
                { number: '000000001', primary: true },
                { number: '000000002', primary: false },
            ],
            email_addresses: [
                { address: 'a@domain.com', primary: false },
                { address: 'b@domain.com', primary: false },
                { address: 'c@domain.com', primary: true },
            ],
        };

        var _this = this;

        this.httpResponse = {};
        spyOn(httpProxy, 'callHttp').and.callFake(function() {
            return $q.resolve(_this.httpResponse);
        });
    }));

    describe('getOrgPermission', function() {
        it("should find the person's organizational permission", function() {
            expect(personService.getOrgPermission(this.person, 1)).toEqual(
                this.organizationalPermission,
            );
        });

        it('should return null when the user has no organizational permission', function() {
            expect(personService.getOrgPermission(this.person, 4)).toBe(null);
        });
    });

    describe('isContact', function() {
        it('should return true for contacts', function() {
            this.person.organizational_permissions = [
                { organization_id: 1, permission_id: 2 },
            ];
            expect(personService.isContact(this.person, 1)).toBe(true);
        });

        it('should return false for users', function() {
            this.person.organizational_permissions = [
                { organization_id: 1, permission_id: 4 },
            ];
            expect(personService.isContact(this.person, 1)).toBe(false);
        });

        it('should return false for admins', function() {
            this.person.organizational_permissions = [
                { organization_id: 1, permission_id: 1 },
            ];
            expect(personService.isContact(this.person, 1)).toBe(false);
        });

        it('should return false for people not on the org', function() {
            this.person.organizational_permissions = [];
            expect(personService.isContact(this.person, 1)).toBe(false);
        });
    });

    describe('getAssignedTo', function() {
        it("should find the person's assignments", function() {
            expect(personService.getAssignedTo(this.person, 1)).toEqual([
                { name: 'Alice' },
                { name: 'Adam' },
            ]);
            expect(personService.getAssignedTo(this.person, 4)).toEqual([]);
        });
    });

    describe('getPhoneNumber', function() {
        it("should find the person's primary phone number", function() {
            expect(personService.getPhoneNumber(this.person)).toEqual({
                number: '000000001',
                primary: true,
            });
        });
    });

    describe('getEmailAddress', function() {
        it("should find the person's primary email address", function() {
            expect(personService.getEmailAddress(this.person)).toEqual({
                address: 'c@domain.com',
                primary: true,
            });
        });
    });

    describe('archivePerson', function() {
        it('should make a network request', function() {
            personService.archivePerson(this.person, 1);
            expect(httpProxy.callHttp).toHaveBeenCalledWith(
                'PUT',
                jasmine.any(String),
                null,
                {
                    data: {
                        type: 'person',
                        attributes: {},
                    },
                    included: [
                        {
                            type: 'organizational_permission',
                            id: 21,
                            attributes: {
                                archive_date: jasmine.any(String),
                            },
                        },
                    ],
                },
                jasmine.objectContaining({ errorMessage: jasmine.any(String) }),
            );
        });

        it(
            "should remove the person from their org's people list",
            asynchronous(function() {
                var _this = this;
                return personService
                    .archivePerson(this.person, 1)
                    .then(function() {
                        expect(
                            _this.organizationalPermission.organization.people,
                        ).toEqual([{ id: 12 }]);
                    });
            }),
        );
    });

    describe('getContactAssignments', function() {
        beforeEach(function() {
            this.organizationId = 1;

            this.personRelevant = {
                id: 101,
                reverse_contact_assignments: [
                    {
                        assigned_to: { id: this.person.id },
                        organization: { id: this.organizationId },
                    },
                ],
                organizational_permissions: [
                    { organization_id: this.organizationId },
                ],
            };
            this.personNotAssigned = {
                id: 102,
                reverse_contact_assignments: [
                    {
                        assigned_to: { id: 123 },
                        organization: { id: this.organizationId },
                    },
                ],
                organizational_permissions: [
                    { organization_id: this.organizationId },
                ],
            };
            this.personNotOnOrg = {
                id: 103,
                reverse_contact_assignments: [
                    {
                        assigned_to: { id: this.person.id },
                        organization: { id: this.organizationId },
                    },
                ],
                organizational_permissions: [{ organization_id: 123 }],
            };
            this.personWrongOrg = {
                id: 104,
                reverse_contact_assignments: [
                    {
                        assigned_to: { id: this.person.id },
                        organization: { id: 123 },
                    },
                ],
                organizational_permissions: [{ organization_id: 123 }],
            };
            this.personOnNoOrg = {
                id: 103,
                reverse_contact_assignments: [
                    {
                        assigned_to: { id: this.person.id },
                    },
                ],
            };
        });

        describe('scoped to organization', function() {
            it('should make a network request', function() {
                personService.getContactAssignments(
                    this.person,
                    this.organizationId,
                );
                expect(httpProxy.callHttp).toHaveBeenCalledWith(
                    'GET',
                    jasmine.any(String),
                    jasmine.objectContaining({
                        include:
                            'reverse_contact_assignments,organizational_permissions',
                        'filters[assigned_tos]': this.person.id,
                        'filters[organizations_id]': this.organizationId,
                    }),
                    null,
                    jasmine.objectContaining({
                        errorMessage: jasmine.any(String),
                    }),
                );
            });

            it(
                'should asynchronously return the relevant contact assignments',
                asynchronous(function() {
                    var _this = this;

                    this.httpResponse = {
                        data: [
                            this.personRelevant,
                            this.personNotAssigned,
                            this.personNotOnOrg,
                            this.personWrongOrg,
                            this.personOnNoOrg,
                        ],
                    };

                    return personService
                        .getContactAssignments(this.person, this.organizationId)
                        .then(function(assignments) {
                            expect(assignments).toEqual([
                                _this.personRelevant
                                    .reverse_contact_assignments[0],
                            ]);
                        });
                }),
            );
        });

        describe('not scoped to organization', function() {
            it('should make a network request', function() {
                personService.getContactAssignments(this.person);
                expect(httpProxy.callHttp).toHaveBeenCalledWith(
                    'GET',
                    jasmine.any(String),
                    jasmine.objectContaining({
                        include:
                            'reverse_contact_assignments.organization,organizational_permissions',
                        'filters[assigned_tos]': this.person.id,
                        'filters[organizations_id]': '',
                    }),
                    null,
                    jasmine.objectContaining({
                        errorMessage: jasmine.any(String),
                    }),
                );
            });

            it(
                'should asynchronously return the relevant contact assignments',
                asynchronous(function() {
                    var _this = this;

                    this.httpResponse = {
                        data: [
                            this.personRelevant,
                            this.personNotAssigned,
                            this.personNotOnOrg,
                            this.personOnNoOrg,
                        ],
                    };

                    return personService
                        .getContactAssignments(this.person)
                        .then(function(assignments) {
                            expect(assignments).toEqual([
                                _this.personRelevant
                                    .reverse_contact_assignments[0],
                            ]);
                        });
                }),
            );
        });
    });
});
