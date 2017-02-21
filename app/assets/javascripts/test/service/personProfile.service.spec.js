(function () {
    'use strict';

    var personProfileService, $q, $rootScope, httpProxy, _;

    // Add better asynchronous support to a test function
    // The test function must return a promise
    // The promise will automatically be bound to "done" and the $rootScope will be automatically digested
    function asynchronous (fn) {
        return function (done) {
            var returnValue = fn.call(this, done);
            returnValue.then(function () {
                done();
            }).catch(function (err) {
                done.fail(err);
            });
            $rootScope.$apply();
            return returnValue;
        };
    }

    describe('personProfileService', function () {
        beforeEach(angular.mock.module('missionhubApp'));

        beforeEach(inject(function (_personProfileService_, _$q_, _$rootScope_, _httpProxy_, ___) {
            personProfileService = _personProfileService_;
            $q = _$q_;
            $rootScope = _$rootScope_;
            httpProxy = _httpProxy_;
            _ = ___;

            this.organizationId = 10;

            this.person = {
                _type: 'person',
                id: 100,
                reverse_contact_assignments: [
                    { _type: 'contact_assignment', id: 1, assigned_to: { id: 101 } },
                    { _type: 'contact_assignment', id: 2, assigned_to: { id: 102 } },
                    { _type: 'contact_assignment', id: 3, assigned_to: { id: 103 } },
                    { _type: 'contact_assignment', id: 4, _placeHolder: true }
                ]
            };

            spyOn(httpProxy, 'callHttp').and.returnValue($q.resolve());
        }));

        describe('saveAttribute', function () {
            beforeEach(function () {
                this.personId = 123;
                this.person = {
                    _type: 'person',
                    id: this.personId,
                    key1: 'value1',
                    key2: 'value2',
                    key3: 'value3'
                };
            });

            it('should update individual person attributes', function () {
                personProfileService.saveAttribute(this.personId, this.person, 'key1');
                expect(httpProxy.callHttp).toHaveBeenCalledWith(
                    'PUT',
                    jasmine.any(String),
                    null,
                    {
                        data: {
                            type: 'person',
                            id: this.personId,
                            attributes: {
                                key1: 'value1'
                            }
                        }
                    },
                    { params: {} }
                );
            });

            it('should update multiple person attributes', function () {
                personProfileService.saveAttribute(this.personId, this.person, ['key1', 'key2', 'key3']);
                expect(httpProxy.callHttp).toHaveBeenCalledWith(
                    'PUT',
                    jasmine.any(String),
                    null,
                    {
                        data: {
                            type: 'person',
                            id: this.personId,
                            attributes: {
                                key1: 'value1',
                                key2: 'value2',
                                key3: 'value3'
                            }
                        }
                    },
                    { params: {} }
                );
            });

            it('should update existing relationships', function () {
                var relationship = {
                    _type: 'organization',
                    id: 456,
                    key11: 'value11'
                };

                personProfileService.saveAttribute(this.personId, relationship, 'key11');

                expect(httpProxy.callHttp).toHaveBeenCalledWith(
                    'PUT',
                    jasmine.any(String),
                    null,
                    {
                        data: {
                            type: 'person'
                        },
                        included: [{
                            type: 'organization',
                            id: 456,
                            attributes: {
                                key11: 'value11'
                            }
                        }]
                    },
                    { params: { } }
                );
            });

            it('should create new relationships', function () {
                var relationship = {
                    _type: 'organization',
                    key21: 'value21',
                    key22: 'value21',
                    key23: 'value23'
                };

                personProfileService.saveAttribute(this.personId, relationship);

                expect(httpProxy.callHttp).toHaveBeenCalledWith(
                    'PUT',
                    jasmine.any(String),
                    null,
                    {
                        data: {
                            type: 'person'
                        },
                        included: [{
                            type: 'organization',
                            attributes: relationship
                        }]
                    },
                    { params: { include: 'organizations' } }
                );
            });
        });

        describe('addAssignments', function () {
            it('should not make a network request when adding no assignments', function () {
                personProfileService.addAssignments(this.person, this.organizationId, []);
                expect(httpProxy.callHttp).not.toHaveBeenCalled();
            });

            it('should make a network request when adding assigments', function () {
                personProfileService.addAssignments(this.person, this.organizationId, [{ id: 104 }, { id: 105 }]);
                expect(httpProxy.callHttp).toHaveBeenCalledWith(
                    'PUT',
                    jasmine.any(String),
                    null,
                    {
                        data: {
                            type: 'person'
                        },
                        included: [{
                            type: 'contact_assignment',
                            attributes: {
                                assigned_to_id: 104,
                                organization_id: this.organizationId
                            }
                        }, {
                            type: 'contact_assignment',
                            attributes: {
                                assigned_to_id: 105,
                                organization_id: this.organizationId
                            }
                        }]
                    },
                    undefined
                );
            });
        });

        describe('removeAssignments', function () {
            beforeEach(function () {
                this.removedPeople = [
                    { id: 101 },
                    { id: 103 },
                    { id: 104 }
                ];
            });

            it('should make a network request for each removed assignment', function () {
                personProfileService.removeAssignments(this.person, this.removedPeople);

                expect(httpProxy.callHttp.calls.allArgs()).toEqual([
                    ['DELETE', jasmine.stringMatching(/\/1$/), undefined, null, undefined], // ends with "/1"
                    ['DELETE', jasmine.stringMatching(/\/3$/), undefined, null, undefined] // ends with "/3"
                ]);
            });

            it('should remove deleted contact assignments', asynchronous(function () {
                var _this = this;
                return personProfileService.removeAssignments(this.person, this.removedPeople).then(function () {
                    expect(_.map(_this.person.reverse_contact_assignments, 'id')).toEqual([2, 4]);
                });
            }));
        });

        describe('formatAddress', function () {
            it('should remove empty address lines', function () {
                expect(personProfileService.formatAddress({
                    address1: '123 Main Street',
                    address2: 'Apt 1234'
                })).toEqual([
                    '123 Main Street',
                    'Apt 1234'
                ]);
            });

            it('should generate the region line', function () {
                var tests = [
                    { address: { city: 'Orlando', state: 'FL', zip: '32832' }, lines: ['Orlando, FL 32832'] },
                    { address: { city: 'Orlando', state: 'FL' }, lines: ['Orlando, FL'] },
                    { address: { city: 'Orlando', zip: '32832' }, lines: ['Orlando 32832'] },
                    { address: { city: 'Orlando' }, lines: ['Orlando'] },
                    { address: { state: 'FL', zip: '32832' }, lines: ['FL 32832'] },
                    { address: { state: 'FL' }, lines: ['FL'] },
                    { address: { zip: '32832' }, lines: ['32832'] },
                    { address: {}, lines: [] }
                ];
                tests.forEach(function (test) {
                    expect(personProfileService.formatAddress(test.address)).toEqual(test.lines);
                });
            });

            it('should hide non-US country lines', function () {
                expect(personProfileService.formatAddress({ country: 'CA' })).toEqual(['CA']);
                expect(personProfileService.formatAddress({ country: 'US' })).toEqual([]);
            });
        });
    });
})();
