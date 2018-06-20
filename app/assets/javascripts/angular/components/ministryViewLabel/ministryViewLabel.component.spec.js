import 'angular-mocks';

// Constants
var $ctrl, $q, $rootScope, JsonApiDataStore;

// Add better asynchronous support to a test function
// The test function must return a promise
// The promise will automatically be bound to "done" and the $rootScope will be automatically digested
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

describe('minstryViewLabel component', function() {
    beforeEach(angular.mock.module('missionhubApp'));

    beforeEach(inject(function(
        $componentController,
        _$q_,
        _$rootScope_,
        _JsonApiDataStore_,
    ) {
        $q = _$q_;
        $rootScope = _$rootScope_;
        JsonApiDataStore = _JsonApiDataStore_;

        this.loggedInPerson = jasmine.createSpyObj('loggedInPerson', [
            'isAdminAt',
        ]);
        this.$uibModal = jasmine.createSpyObj('$uibModal', ['open']);
        this.confirmModalService = jasmine.createSpyObj('confirmModalService', [
            'create',
        ]);
        this.labelsService = jasmine.createSpyObj('labelsService', [
            'deleteLabel',
        ]);

        this.organization = new JsonApiDataStore.Model('organization', 1);
        this.organization.setRelationship('labels', []);

        this.label = new JsonApiDataStore.Model('label');
        this.label.setAttribute('id', 1);
        this.label.setAttribute('name', 'Test label');
        this.label.setRelationship('organization', this.organization);

        $ctrl = $componentController(
            'ministryViewLabel',
            {
                loggedInPerson: this.loggedInPerson,
                $uibModal: this.$uibModal,
                confirmModalService: this.confirmModalService,
                labelsService: this.labelsService,
            },
            {
                label: this.label,
            },
        );
    }));

    describe('$onInit', function() {
        it('should initialize admin privileges', function() {
            this.loggedInPerson.isAdminAt.and.returnValue(true);

            $ctrl.$onInit();

            expect(this.loggedInPerson.isAdminAt).toHaveBeenCalledWith(
                this.organization,
            );
            expect($ctrl.adminPrivileges).toEqual(true);
        });
    });

    describe('editLabel', function() {
        it('should open the edit label modal', function() {
            $ctrl.editLabel();

            expect(this.$uibModal.open).toHaveBeenCalledWith(
                jasmine.objectContaining({
                    component: 'editLabel',
                }),
            );
            expect(
                this.$uibModal.open.calls
                    .argsFor(0)[0]
                    .resolve.organizationId(),
            ).toEqual(this.organization.id);
            expect(
                this.$uibModal.open.calls.argsFor(0)[0].resolve.label(),
            ).toEqual(this.label);
        });
    });

    describe('deleteLabel', function() {
        beforeEach(function() {
            this.confirmModalService.create.and.returnValue($q.resolve());
            this.labelsService.deleteLabel.and.returnValue($q.resolve());
        });

        it('should open the confirmation dialog', function() {
            $ctrl.deleteLabel();

            expect(this.confirmModalService.create).toHaveBeenCalled();
        });

        it(
            'should delete the label',
            asynchronous(function() {
                var _this = this;

                return $ctrl.deleteLabel().then(function() {
                    expect(
                        _this.labelsService.deleteLabel,
                    ).toHaveBeenCalledWith(_this.label);
                });
            }),
        );
    });
});
