(function () {
    'use strict';

    // Constants
    var interactionsService, $q, $rootScope, httpProxy, reportsService, _;

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

    describe('interactionsService', function () {
        beforeEach(angular.mock.module('missionhubApp'));

        beforeEach(function () {
            var _this = this;

            // Mock out the loggedInPerson service
            angular.mock.module(function ($provide) {
                $provide.factory('loggedInPerson', function () {
                    return {
                        person: {
                            get id () {
                                return _this.loggedInPersonId;
                            }
                        }
                    };
                });
            });
        });

        beforeEach(inject(function (_interactionsService_, _$q_, _$rootScope_, _httpProxy_, _reportsService_, ___) {
            interactionsService = _interactionsService_;
            $q = _$q_;
            $rootScope = _$rootScope_;
            httpProxy = _httpProxy_;
            reportsService = _reportsService_;
            _ = ___;

            this.interaction = {
                interactionTypeId: 1,
                comment: 'Additional info'
            };
            this.organizationId = 2;
            this.initiatorId = 3;
            this.loggedInPersonId = 123;
            this.interactionModel = {
                interaction_type_id: this.interaction.interactionTypeId,
                organization: { id: this.organizationId },
                initiators: [
                    { id: this.initiatorId }
                ]
            };

            spyOn(httpProxy, 'callHttp').and.callFake(function () {
                return $q.resolve({ data: {} });
            });
        }));

        describe('getInteractionTypes', function () {
            it('should not include deprecated interaction types', function () {
                expect(_.find(interactionsService.getInteractionTypes(), { id: 6 })).not.toBeDefined();
            });
        });

        describe('getInteractionType', function () {
            it('should find interaction types', function () {
                expect(interactionsService.getInteractionType(1)).toBeDefined();
            });

            it('should find deprecated interaction types', function () {
                expect(interactionsService.getInteractionType(6)).toBeDefined();
            });
        });

        describe('recordInteraction', function () {
            it('with no personId should create an anyonymous interaction', function () {
                interactionsService.recordInteraction(this.interaction, this.organizationId);
                expect(httpProxy.callHttp).toHaveBeenCalledWith(
                    'POST',
                    jasmine.any(String),
                    null,
                    {
                        data: {
                            type: 'interaction',
                            attributes: {
                                comment: this.interaction.comment,
                                interaction_type_id: this.interaction.interactionTypeId
                            },
                            relationships: {
                                organization: {
                                    data: { id: this.organizationId, type: 'organization' }
                                }
                            }
                        },
                        included: [{
                            type: 'interaction_initiator',
                            attributes: {
                                person_id: this.loggedInPersonId
                            }
                        }]
                    },
                    jasmine.objectContaining({ errorMessage: jasmine.any(String) })
                );
            });

            it('with personId should create a personal interaction', function () {
                interactionsService.recordInteraction(this.interaction, this.organizationId, this.initiatorId);
                expect(httpProxy.callHttp).toHaveBeenCalledWith(
                    'POST',
                    jasmine.any(String),
                    null,
                    {
                        data: {
                            type: 'interaction',
                            attributes: {
                                comment: this.interaction.comment,
                                interaction_type_id: this.interaction.interactionTypeId
                            },
                            relationships: {
                                organization: {
                                    data: { id: this.organizationId, type: 'organization' }
                                },
                                receiver: {
                                    data: { id: this.initiatorId, type: 'person' }
                                }
                            }
                        },
                        included: [{
                            type: 'interaction_initiator',
                            attributes: {
                                person_id: this.loggedInPersonId
                            }
                        }]
                    },
                    jasmine.objectContaining({ errorMessage: jasmine.any(String) })
                );
            });

            it('extracts and returns returns the new interaction model', asynchronous(function () {
                var _this = this;
                spyOn(httpProxy, 'extractModel').and.returnValue(this.interactionModel);
                return interactionsService.recordInteraction(this.interaction, this.organizationId, this.initiatorId)
                    .then(function (newInteraction) {
                        expect(newInteraction).toBe(_this.interactionModel);
                    });
            }));

            it('updates person and organization reports', asynchronous(function () {
                var _this = this;
                var personReport = {};
                var organizationReport = {};
                spyOn(httpProxy, 'extractModel').and.returnValue(this.interactionModel);
                spyOn(reportsService, 'lookupPersonReport').and.returnValue(personReport);
                spyOn(reportsService, 'lookupOrganizationReport').and.returnValue(organizationReport);
                spyOn(reportsService, 'incrementReportInteraction');
                return interactionsService.recordInteraction(this.interaction, this.organizationId, this.initiatorId)
                    .then(function () {
                        expect(reportsService.lookupPersonReport).toHaveBeenCalledWith(
                            _this.organizationId,
                            _this.initiatorId
                        );

                        expect(reportsService.lookupOrganizationReport).toHaveBeenCalledWith(
                            _this.organizationId
                        );

                        expect(reportsService.incrementReportInteraction.calls.allArgs()).toEqual([
                            [organizationReport, _this.interaction.interactionTypeId],
                            [personReport, _this.interaction.interactionTypeId]
                        ]);
                    });
            }));
        });
    });
})();
