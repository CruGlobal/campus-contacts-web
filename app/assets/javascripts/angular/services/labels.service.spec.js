import 'angular-mocks';

// Constants
var labelsService, $q, $rootScope, httpProxy, JsonApiDataStore;

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

describe('labelsService', function() {
    beforeEach(inject(function(
        _labelsService_,
        _$q_,
        _$rootScope_,
        _httpProxy_,
        _JsonApiDataStore_,
    ) {
        var _this = this;

        labelsService = _labelsService_;
        $q = _$q_;
        $rootScope = _$rootScope_;
        httpProxy = _httpProxy_;
        JsonApiDataStore = _JsonApiDataStore_;

        this.organization = new JsonApiDataStore.Model('organization', 1);
        this.organization.setRelationship('labels', []);
        JsonApiDataStore.store.sync(this.organization.serialize());

        this.label = new JsonApiDataStore.Model('label');
        this.label.setAttribute('name', 'Test label');
        this.label.setRelationship('organization', this.organization);

        // Can be changed in individual tests
        this.httpResponse = $q.resolve({
            data: this.label,
        });
        spyOn(httpProxy, 'post').and.callFake(function() {
            return _this.httpResponse;
        });
        spyOn(httpProxy, 'put').and.callFake(function() {
            return _this.httpResponse;
        });
        spyOn(httpProxy, 'delete').and.callFake(function() {
            return _this.httpResponse;
        });
    }));

    describe('getLabelTemplate', function() {
        it('should create an empty label', function() {
            expect(
                labelsService.getLabelTemplate(this.organization.id),
            ).toEqual(
                jasmine.objectContaining({
                    id: undefined,
                    _type: 'label',
                    _attributes: ['name'],
                    _relationships: ['organization'],
                    name: '',
                    organization: this.organization,
                }),
            );
        });
    });

    describe('createLabel', function() {
        it('should make a network request', function() {
            labelsService.createLabel(this.label);

            expect(httpProxy.post).toHaveBeenCalled();
        });

        it(
            'should return a promise that resolves to the new label',
            asynchronous(function() {
                var _this = this;

                return labelsService
                    .createLabel(this.label)
                    .then(function(label) {
                        expect(label).toBe(_this.label);
                    });
            }),
        );

        it(
            'should add the label to the organization',
            asynchronous(function() {
                var _this = this;
                this.organization.labels = [];
                return labelsService
                    .createLabel(this.label)
                    .then(function(label) {
                        expect(_this.organization.labels).toEqual([label]);
                    });
            }),
        );
    });

    describe('updateLabel', function() {
        beforeEach(function() {
            this.label.setAttribute('id', 1);
        });

        it('should make a network request', function() {
            labelsService.updateLabel(this.label);

            expect(httpProxy.put).toHaveBeenCalled();
        });

        it(
            'should return a promise that resolves to the label',
            asynchronous(function() {
                var _this = this;

                return labelsService
                    .updateLabel(this.label)
                    .then(function(label) {
                        expect(label).toBe(_this.label);
                    });
            }),
        );

        it(
            'should edit the label in the organization',
            asynchronous(function() {
                var _this = this;
                this.organization.setRelationship('labels', [this.label]);
                this.label.name = 'New Name';

                return labelsService
                    .updateLabel(this.label)
                    .then(function(label) {
                        expect(_this.organization.labels).toEqual([label]);
                    });
            }),
        );
    });

    describe('saveLabel', function() {
        it('should create a new label if the label has no id', function() {
            spyOn(labelsService, 'createLabel');

            labelsService.saveLabel(this.label);

            expect(labelsService.createLabel).toHaveBeenCalledWith(this.label);
        });

        it('should update a label if the label has an id', function() {
            this.label.setAttribute('id', 1);
            spyOn(labelsService, 'updateLabel');

            labelsService.saveLabel(this.label);

            expect(labelsService.updateLabel).toHaveBeenCalledWith(this.label);
        });
    });

    describe('deleteLabel', function() {
        it(
            'should remove the label from the organization',
            asynchronous(function() {
                var _this = this;
                this.organization.labels = [this.label];

                return labelsService.deleteLabel(this.label).then(function() {
                    expect(_this.organization.labels).toEqual([]);
                    expect(httpProxy.delete).toHaveBeenCalled();
                });
            }),
        );
    });

    describe('payloadFromLabel', function() {
        it('should generate a JSON API payload', function() {
            this.label = new JsonApiDataStore.Model('label', 3);
            this.label.setAttribute('name', 'Label');
            this.label.setRelationship('organization', this.organization);

            expect(labelsService.payloadFromLabel(this.label)).toEqual({
                data: {
                    type: 'label',
                    id: 3,
                    attributes: {
                        name: 'Label',
                    },
                },
            });
        });

        it('should include organization id if it is a new label', function() {
            this.people = [];

            this.label = new JsonApiDataStore.Model('label');
            this.label.setAttribute('name', 'Label');
            this.label.setRelationship('organization', this.organization);

            expect(labelsService.payloadFromLabel(this.label)).toEqual({
                data: {
                    type: 'label',
                    attributes: {
                        name: 'Label',
                    },
                    relationships: {
                        organization: {
                            data: {
                                id: this.organization.id,
                                type: 'organization',
                            },
                        },
                    },
                },
            });
        });
    });
});
