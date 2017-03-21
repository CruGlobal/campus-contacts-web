(function () {
    'use strict';

    // Constants
    var multiselectListService, _;

    describe('multiselectListService', function () {
        beforeEach(angular.mock.module('missionhubApp'));

        beforeEach(inject(function (_multiselectListService_, ___) {
            multiselectListService = _multiselectListService_;
            _ = ___;
        }));

        describe('state checks', function () {
            beforeEach(function () {
                this.id = 1;
                this.selected = { 1: true };
                this.unselected = { 1: false };
                this.indeterminate = { 1: null };
                this.missing = {};
            });

            describe('isSelected', function () {
                it('should return true for selected states', function () {
                    expect(multiselectListService.isSelected(this.selected, this.id)).toBe(true);
                });

                it('should return false for other states', function () {
                    expect(multiselectListService.isSelected(this.unselected, this.id)).toBe(false);
                    expect(multiselectListService.isSelected(this.indeterminate, this.id)).toBe(false);
                    expect(multiselectListService.isSelected(this.missing, this.id)).toBe(false);
                });
            });

            describe('isUnselected', function () {
                it('should return true for unselected and missing states', function () {
                    expect(multiselectListService.isUnselected(this.unselected, this.id)).toBe(true);
                    expect(multiselectListService.isUnselected(this.missing, this.id)).toBe(true);
                });

                it('should return false for other states', function () {
                    expect(multiselectListService.isUnselected(this.selected, this.id)).toBe(false);
                    expect(multiselectListService.isUnselected(this.indeterminate, this.id)).toBe(false);
                });
            });

            describe('isIndeterminate', function () {
                it('should return true for indeterminate states', function () {
                    expect(multiselectListService.isIndeterminate(this.indeterminate, this.id)).toBe(true);
                });

                it('should return false for other states', function () {
                    expect(multiselectListService.isIndeterminate(this.selected, this.id)).toBe(false);
                    expect(multiselectListService.isIndeterminate(this.unselected, this.id)).toBe(false);
                    expect(multiselectListService.isIndeterminate(this.missing, this.id)).toBe(false);
                });
            });
        });

        describe('toggle', function () {
            var id = 1;
            var states = {
                selected: { 1: true },
                unselected: { 1: false },
                indeterminate: { 1: null },
                missing: {}
            };
            var output = {
                present: [id],
                absent: []
            };

            var tests = [
                {
                    initialSelection: 'selected',
                    currentSelection: 'selected',
                    addedOutput: 'absent',
                    removedOutput: 'absent',
                    expectedSelected: 'unselected',
                    expectedAddedOutput: 'absent',
                    expectedRemovedOutput: 'present'
                }, {
                    initialSelection: 'unselected',
                    currentSelection: 'selected',
                    addedOutput: 'present',
                    removedOutput: 'absent',
                    expectedSelected: 'unselected',
                    expectedAddedOutput: 'absent',
                    expectedRemovedOutput: 'absent'
                }, {
                    initialSelection: 'indeterminate',
                    currentSelection: 'selected',
                    addedOutput: 'present',
                    removedOutput: 'absent',
                    expectedSelected: 'unselected',
                    expectedAddedOutput: 'absent',
                    expectedRemovedOutput: 'present'
                },

                {
                    initialSelection: 'selected',
                    currentSelection: 'unselected',
                    addedOutput: 'absent',
                    removedOutput: 'present',
                    expectedSelected: 'selected',
                    expectedAddedOutput: 'absent',
                    expectedRemovedOutput: 'absent'
                }, {
                    initialSelection: 'unselected',
                    currentSelection: 'unselected',
                    addedOutput: 'absent',
                    removedOutput: 'absent',
                    expectedSelected: 'selected',
                    expectedAddedOutput: 'present',
                    expectedRemovedOutput: 'absent'
                }, {
                    initialSelection: 'indeterminate',
                    currentSelection: 'unselected',
                    addedOutput: 'present',
                    removedOutput: 'absent',
                    expectedSelected: 'indeterminate',
                    expectedAddedOutput: 'absent',
                    expectedRemovedOutput: 'absent'
                },

                {
                    initialSelection: 'indeterminate',
                    currentSelection: 'indeterminate',
                    addedOutput: 'absent',
                    removedOutput: 'absent',
                    expectedSelected: 'selected',
                    expectedAddedOutput: 'present',
                    expectedRemovedOutput: 'absent'
                },

                {
                    initialSelection: 'missing',
                    currentSelection: 'missing',
                    addedOutput: 'absent',
                    removedOutput: 'absent',
                    expectedSelected: 'selected',
                    expectedAddedOutput: 'present',
                    expectedRemovedOutput: 'absent'
                }
            ];

            tests.forEach(function (test) {
                var testText = 'should toggle ' + test.currentSelection +
                               ' state that was initially ' + test.initialSelection;
                it(testText, function () {
                    var currentSelection = _.clone(states[test.currentSelection]);
                    var addedOutput = _.clone(output[test.addedOutput]);
                    var removedOutput = _.clone(output[test.removedOutput]);

                    multiselectListService.toggle(id, {
                        originalSelection: states[test.initialSelection],
                        currentSelection: currentSelection,
                        addedOutput: addedOutput,
                        removedOutput: removedOutput
                    });

                    expect(currentSelection).toEqual(states[test.expectedSelected]);
                    expect(addedOutput).toEqual(output[test.expectedAddedOutput]);
                    expect(removedOutput).toEqual(output[test.expectedRemovedOutput]);
                });
            });
        });
    });
})();
