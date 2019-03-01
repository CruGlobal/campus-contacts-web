describe('peopleScreen component', function() {
    var $ctrl, loggedInPerson;

    beforeEach(inject(function($componentController) {
        loggedInPerson = jasmine.createSpyObj('loggedInPerson', ['isAdminAt']);

        $ctrl = $componentController(
            'peopleScreen',
            {
                loggedInPerson: loggedInPerson,
            },
            {
                org: {
                    id: 1,
                },
            },
        );
    }));

    describe('$onInit', function() {
        it('should initialize the component', function() {
            loggedInPerson.isAdminAt.and.returnValue(true);
            $ctrl.$onInit();
            expect(loggedInPerson.isAdminAt).toHaveBeenCalledWith({ id: 1 });
            expect($ctrl.isAdmin).toEqual(true);
        });
    });
});
