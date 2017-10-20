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

            this.label = new JsonApiDataStore.Model('label');
            this.label.setAttribute('id', 1);
            this.label.setAttribute('name', 'Test label');
            this.label.setRelationship('organization', this.organization);

            this.organization.setRelationship('labels', [this.label]);

            $ctrl = $componentController('organizationOverviewLabels', {
                $uibModal: this.$uibModal
            }, {
                organizationOverview: {
                    org: this.organization
                }
            });
        }));

        it('should make the labels available to the template', function () {
            expect($ctrl.organizationOverview.org.labels).toEqual([this.label]);
        });

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
