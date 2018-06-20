angular
    .module('missionhubApp')
    .factory('multiselectListService', multiselectListService);

function multiselectListService(_) {
    /*
     * Throughout the multiselectListService API, a "selection" is a hash where the key is the option id and the
     * value is the option's selection state. That state is an enumeration where true represents selected, false
     * represents unselected, and null represents indeterminate.
     */
    var multiselectListService = {
        // Return a boolean indicating whether or not an option is selected
        isSelected: function(selection, id) {
            return selection[id] === true;
        },

        // Return a boolean indicating whether or not an option is unselected
        isUnselected: function(selection, id) {
            var state = selection[id];
            return typeof state === 'undefined' || state === false;
        },

        // Return a boolean indicating whether or not an option is in the indeterminate state
        isIndeterminate: function(selection, id) {
            return selection[id] === null;
        },

        // Toggle the state of an option, taking indeterminate states into account
        // The listState is an object with an "originalSelection" field that specifies the initial selection state,
        // a "currentSelection" field that specifies the current selection state, an "addedOutput" field that is an
        // array of all the option ids added to the current selection versus the original selection, and a
        // "removedOutput" field that is an array of all the option ids removed from the current selection versus
        // the original selection.
        // This method will update "currentSelection", "addedOutput", and "removedOutput" as necessary, while
        // leaving "originalSelection" untouched.
        toggle: function(id, listState) {
            var originalSelection = listState.originalSelection;
            var currentSelection = listState.currentSelection;
            var addedOutput = listState.addedOutput;
            var removedOutput = listState.removedOutput;

            var newState;
            if (multiselectListService.isSelected(currentSelection, id)) {
                // Selected toggles to unselected
                newState = false;
            } else if (
                multiselectListService.isUnselected(currentSelection, id)
            ) {
                // Unselected toggles to indeterminate if available and selected otherwise
                newState = multiselectListService.isIndeterminate(
                    originalSelection,
                    id,
                )
                    ? null
                    : true;
            } else if (
                multiselectListService.isIndeterminate(currentSelection, id)
            ) {
                // Indeterminate toggles to selected
                newState = true;
            }

            currentSelection[id] = newState;

            if (multiselectListService.isSelected(currentSelection, id)) {
                _.pull(removedOutput, id);

                // don't add to added diff if it was one of the original selections
                if (!multiselectListService.isSelected(originalSelection, id)) {
                    addedOutput.push(id);
                }
            } else if (
                multiselectListService.isUnselected(currentSelection, id)
            ) {
                _.pull(addedOutput, id);

                // don't flag something to be removed if it wasn't there in the first place
                if (
                    !multiselectListService.isUnselected(originalSelection, id)
                ) {
                    removedOutput.push(id);
                }
            } else if (
                multiselectListService.isIndeterminate(currentSelection, id)
            ) {
                _.pull(removedOutput, id);
                _.pull(addedOutput, id);
            }
        },
    };

    return multiselectListService;
}
