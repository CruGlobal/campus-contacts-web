describe('interaction component', function() {
    beforeEach(angular.mock.module('missionhubApp'));

    var $ctrl, $q, $rootScope, interactionsService, confirmModalService;

    beforeEach(inject(function(
        $componentController,
        _$q_,
        _$timeout_,
        _$rootScope_,
    ) {
        interactionsService = jasmine.createSpyObj('interactionsService', [
            'getInteractionType',
            'updateInteraction',
            'deleteInteraction',
        ]);
        confirmModalService = jasmine.createSpyObj('confirmModalService', [
            'create',
        ]);

        $ctrl = $componentController(
            'interaction',
            {
                interactionsService: interactionsService,
                confirmModalService: confirmModalService,
            },
            {
                interaction: {
                    id: 1,
                    interaction_type_id: 4,
                },
                onDelete: jasmine.createSpy('onDelete'),
            },
        );
        $q = _$q_;
        $rootScope = _$rootScope_;
    }));

    describe('$onInit', function() {
        it('should populate interactionType', function() {
            interactionsService.getInteractionType.and.returnValue('Test type');

            $ctrl.$onInit();

            expect(interactionsService.getInteractionType).toHaveBeenCalledWith(
                $ctrl.interaction.interaction_type_id,
            );
            expect($ctrl.interactionType).toEqual('Test type');
        });
    });

    describe('updateInteraction', function() {
        it('should update the interaction', function() {
            interactionsService.updateInteraction.and.returnValue($q.resolve());

            $ctrl.updateInteraction();

            expect($ctrl.modifyInteractionState).toEqual('saving');
            expect(interactionsService.updateInteraction).toHaveBeenCalledWith(
                $ctrl.interaction,
            );

            $rootScope.$digest();

            expect($ctrl.modifyInteractionState).toEqual('view');
        });
        it('should handle an error updating the interaction', function() {
            interactionsService.updateInteraction.and.returnValue($q.reject());

            $ctrl.updateInteraction();

            expect($ctrl.modifyInteractionState).toEqual('saving');
            expect(interactionsService.updateInteraction).toHaveBeenCalledWith(
                $ctrl.interaction,
            );

            $rootScope.$digest();

            expect($ctrl.modifyInteractionState).toEqual('edit');
        });
    });

    describe('deleteInteraction', function() {
        it('should delete the interaction', function() {
            confirmModalService.create.and.returnValue($q.resolve());

            $ctrl.deleteInteraction();

            expect($ctrl.modifyInteractionState).toEqual('saving');
            expect(confirmModalService.create).toHaveBeenCalledWith(
                jasmine.any(String),
            );

            interactionsService.deleteInteraction.and.returnValue($q.resolve());
            $rootScope.$digest();

            expect(interactionsService.deleteInteraction).toHaveBeenCalledWith(
                $ctrl.interaction,
            );
            $rootScope.$digest();

            expect($ctrl.onDelete).toHaveBeenCalledWith({
                $event: {
                    interaction: $ctrl.interaction,
                },
            });
        });
        it('should handle an error deleting the interaction', function() {
            confirmModalService.create.and.returnValue($q.resolve());

            $ctrl.deleteInteraction();

            expect($ctrl.modifyInteractionState).toEqual('saving');
            expect(confirmModalService.create).toHaveBeenCalledWith(
                jasmine.any(String),
            );

            interactionsService.deleteInteraction.and.returnValue($q.reject());

            $rootScope.$digest();

            expect(interactionsService.deleteInteraction).toHaveBeenCalledWith(
                $ctrl.interaction,
            );

            $rootScope.$digest();

            expect($ctrl.onDelete).not.toHaveBeenCalled();
            expect($ctrl.modifyInteractionState).toEqual('view');
        });
    });
});
