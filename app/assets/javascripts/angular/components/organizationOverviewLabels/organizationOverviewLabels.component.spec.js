(function () {
    'use strict';

    // Constants
    var $ctrl, JsonApiDataStore;

    describe('organizationOverviewLabels component', function () {
        beforeEach(angular.mock.module('missionhubApp'));

        beforeEach(inject(function ($componentController, _JsonApiDataStore_) {
            JsonApiDataStore = _JsonApiDataStore_;

            this.$uibModal = jasmine.createSpyObj('$uibModal', ['open']);

            this.organization = new JsonApiDataStore.Model('organization', 1);

            $ctrl = $componentController('organizationOverviewLabels', {
                $uibModal: this.$uibModal
            }, {
                organizationOverview: {
                    org: this.organization
                }
            });
        }));

        describe('addLabel', function () {
            it('should open the edit label modal', function () {
                $ctrl.addLabel();
                expect(this.$uibModal.open).toHaveBeenCalledWith(jasmine.objectContaining({
                    component: 'editLabel'
                }));
                expect(this.$uibModal.open.calls.argsFor(0)[0].resolve.organizationId()).toEqual(this.organization.id);
            });
        });
    });
})();
