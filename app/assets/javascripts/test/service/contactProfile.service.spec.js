(function () {
    'use strict';

    var contactProfileService, $q, $rootScope, httpProxy, _;

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

    describe('contactProfileService', function () {
        beforeEach(angular.mock.module('missionhubApp'));

        beforeEach(inject(function (_contactProfileService_, _$q_, _$rootScope_, _httpProxy_, ___) {
            contactProfileService = _contactProfileService_;
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

        describe('addAssignments', function () {
            it('should not make a network request when adding no assignments', function () {
                contactProfileService.addAssignments(this.person, this.organizationId, []);
                expect(httpProxy.callHttp).not.toHaveBeenCalled();
            });

            it('should make a network request when adding assigments', function () {
                contactProfileService.addAssignments(this.person, this.organizationId, [{ id: 104 }, { id: 105 }]);
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
                contactProfileService.removeAssignments(this.person, this.removedPeople);

                expect(httpProxy.callHttp.calls.allArgs()).toEqual([
                    ['DELETE', jasmine.stringMatching(/\/1$/), undefined, null, undefined], // ends with "/1"
                    ['DELETE', jasmine.stringMatching(/\/3$/), undefined, null, undefined] // ends with "/3"
                ]);
            });

            it('should remove deleted contact assignments', asynchronous(function () {
                var _this = this;
                return contactProfileService.removeAssignments(this.person, this.removedPeople).then(function () {
                    expect(_.map(_this.person.reverse_contact_assignments, 'id')).toEqual([2, 4]);
                });
            }));
        });
    });
})();
