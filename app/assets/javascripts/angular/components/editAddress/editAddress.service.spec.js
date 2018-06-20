import 'angular-mocks';

// Constants
var editAddressService, $q, $rootScope, _;

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

describe('editAddressService', function() {
    beforeEach(angular.mock.module('missionhubApp'));

    beforeEach(inject(function(
        _editAddressService_,
        _$q_,
        _$rootScope_,
        geoDataService,
        ___,
    ) {
        editAddressService = _editAddressService_;
        $q = _$q_;
        $rootScope = _$rootScope_;
        _ = ___;

        this.address1 = { id: 1, address_type: 'type1' };
        this.address2 = { id: 2, address_type: 'type2' };
        this.address3 = { id: 3, address_type: 'type3' };

        var countries = [
            { shortCode: 'AA' },
            { shortCode: 'BA' },
            { shortCode: 'CA' },
            {
                shortCode: 'US',
                regions: [
                    { shortCode: 'AL' },
                    { shortCode: 'AK' },
                    { shortCode: 'AZ' },
                ],
            },
        ];
        spyOn(geoDataService, 'getCountries').and.returnValue(
            $q.resolve(countries),
        );
    }));

    describe('getAddressTypes', function() {
        it('should return an array', function() {
            expect(editAddressService.getAddressTypes()).toEqual(
                jasmine.any(Array),
            );
        });
    });

    describe('isAddressTypeValid', function() {
        beforeEach(function() {
            this.otherAddresses = [this.address1, this.address2];
            spyOn(editAddressService, 'getAddressTypes').and.returnValue([
                'type1',
                'type2',
                'type3',
            ]);
        });

        it('should treat unused address types as valid', function() {
            expect(
                editAddressService.isAddressTypeValid(
                    'type3',
                    this.otherAddresses,
                ),
            ).toBe(true);
        });

        it('should treat used address types as invalid', function() {
            expect(
                editAddressService.isAddressTypeValid(
                    'type1',
                    this.otherAddresses,
                ),
            ).toBe(false);
        });
    });

    describe('isAddressValid', function() {
        it('should treat addresses without a type as invalid', function() {
            expect(
                editAddressService.isAddressValid({ address_type: null }),
            ).toBe(false);
        });

        it('should treat addresses with a type as valid', function() {
            expect(
                editAddressService.isAddressValid({ address_type: 'type' }),
            ).toBe(true);
        });
    });

    describe('getAddressTemplate', function() {
        it('should set the required address fields', function() {
            var person = {
                id: 1,
            };
            expect(editAddressService.getAddressTemplate(person)).toEqual(
                jasmine.objectContaining({
                    _type: 'address',
                    person_id: person.id,
                    address_type: jasmine.any(String),
                }),
            );
        });

        it('should choose the first available address type', function() {
            spyOn(editAddressService, 'getAddressTypes').and.returnValue([
                'type1',
                'type2',
                'type3',
            ]);

            expect(
                editAddressService.getAddressTemplate({
                    id: 1,
                    addresses: [],
                }),
            ).toEqual(
                jasmine.objectContaining({
                    address_type: 'type1',
                }),
            );

            expect(
                editAddressService.getAddressTemplate({
                    id: 1,
                    addresses: [this.address1, this.address3],
                }),
            ).toEqual(
                jasmine.objectContaining({
                    address_type: 'type2',
                }),
            );

            expect(
                editAddressService.getAddressTemplate({
                    id: 1,
                    addresses: [this.address1, this.address2, this.address3],
                }),
            ).toEqual(
                jasmine.objectContaining({
                    address_type: null,
                }),
            );
        });
    });

    describe('getCountryOptions', function() {
        it(
            'should prioritize certain countries',
            asynchronous(function() {
                return editAddressService
                    .getCountryOptions()
                    .then(function(countryOptions) {
                        expect(_.map(countryOptions, 'shortCode')).toEqual([
                            'US',
                            'CA',
                            'AA',
                            'BA',
                        ]);
                    });
            }),
        );
    });

    describe('getRegionOptions', function() {
        it(
            "should return the country's regions",
            asynchronous(function() {
                return editAddressService
                    .getRegionOptions('US')
                    .then(function(regionOptions) {
                        expect(_.map(regionOptions, 'shortCode')).toEqual([
                            'AL',
                            'AK',
                            'AZ',
                        ]);
                    });
            }),
        );

        it(
            'should return an empty array for an invalid country',
            asynchronous(function() {
                return editAddressService
                    .getRegionOptions('foo')
                    .then(function(regionOptions) {
                        expect(_.map(regionOptions, 'shortCode')).toEqual([]);
                    });
            }),
        );
    });
});
