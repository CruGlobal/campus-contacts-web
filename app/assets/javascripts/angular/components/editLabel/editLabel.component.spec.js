import 'angular-mocks';

// Constants
var $ctrl, $q, $rootScope, JsonApiDataStore;

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

describe('editLabel component', function () {
    beforeEach(angular.mock.module('missionhubApp'));

    beforeEach(inject(function ($componentController, _$q_, _$rootScope_, _JsonApiDataStore_) {
        $q = _$q_;
        $rootScope = _$rootScope_;
        JsonApiDataStore = _JsonApiDataStore_;

        this.labelsService = jasmine.createSpyObj('labelsService', ['getLabelTemplate', 'saveLabel']);
        this.close = jasmine.createSpy('close');
        this.dismiss = jasmine.createSpy('dismiss');

        this.label = new JsonApiDataStore.Model('label');
        this.label.setAttribute('id', 1);
        this.label.setAttribute('name', 'Test label');

        $ctrl = $componentController('editLabel', {
            labelsService: this.labelsService
        }, {
            resolve: {
                organizationId: 1,
                label: this.label
            },
            close: this.close,
            dismiss: this.dismiss
        });
    }));

    describe('$onInit', function () {
        it('should initialize and create a label if one doesn\'t exist', function () {
            delete $ctrl.resolve.label;
            this.labelsService.getLabelTemplate.and.returnValue({ name: 'New Label' });

            $ctrl.$onInit();

            expect($ctrl.orgId).toEqual(1);
            expect($ctrl.label).toEqual({ name: 'New Label' });
            expect($ctrl.title).toEqual('labels.new.new_label');
        });
    });

    describe('valid', function () {
        beforeEach(function () {
            $ctrl.$onInit();
        });

        it('should return true if the edited label has a name', function () {
            expect($ctrl.valid()).toEqual(true);
        });

        it('should return false if the edited label is empty', function () {
            $ctrl.label.name = '';
            expect($ctrl.valid()).toEqual(false);
        });
    });

    describe('save', function () {
        beforeEach(function () {
            $ctrl.$onInit();
        });

        it('should save the edited label', asynchronous(function () {
            var _this = this;
            this.labelsService.saveLabel.and.returnValue($q.resolve({ name: 'Saved Label' }));

            return $ctrl.save()
                .then(function () {
                    expect(_this.labelsService.saveLabel).toHaveBeenCalledWith(_this.label);
                    expect(_this.close).toHaveBeenCalledWith({ $value: { name: 'Saved Label' } });
                    expect($ctrl.saving).toEqual(true);
                });
        }));

        it('should handle an error saving the edited label', asynchronous(function () {
            var _this = this;
            this.labelsService.saveLabel.and.returnValue($q.reject());

            return $ctrl.save()
                .then(function () {
                    expect(_this.labelsService.saveLabel).toHaveBeenCalledWith(_this.label);
                    expect($ctrl.saving).toEqual(false);
                });
        }));
    });
});
