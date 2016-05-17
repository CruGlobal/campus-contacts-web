(function(){
    angular
        .module('missionhubApp')
        .component('myContactsDashboard', {
            controller: angularTestController,
            templateUrl: '/templates/myContactsDashboard.html'
        });

    function angularTestController($http, $q, state) {
        var vm = this;
        vm.contacts = [];
        vm.organization_contacts = {};
        vm.loading = true;

        vm.org_name = org_name;

        activate();

        function activate() {
            $q.all([loadContacts(), loadOrganizations()]).then(contactsLoaded);
        }

        function loadContacts() {
            return $http
                .get('http://localhost:3001/apis/v4/people', {
                    params: {
                        access_token: state.v4_access_token, limit: 100
                    }
                })
                .then(function (request) {
                    var store = new JsonApiDataStore();
                    store.sync(request.data);
                    vm.contacts = store.findAll('person');
                    vm.loading = false;

                })
        }

        function loadOrganizations() {
            return $http
                .get('http://localhost:3001/apis/v4/organizations', {
                    params: {
                        access_token: state.v4_access_token,
                        include : 'organization.name,organization.id'
                    }
                })
                .then(function(request) {
                    var store = new JsonApiDataStore();
                    store.sync(request.data);
                    vm.organizations = store;
                })
        }

        function contactsLoaded() {
            vm.organization_contacts = {};
            angular.forEach(vm.contacts, function (contact) {
                angular.forEach(contact.organizational_permissions, function(op) {
                    var org_id = op.organization_id;
                    if(vm.organization_contacts[org_id] === undefined)
                        vm.organization_contacts[org_id] = [contact];
                    else
                        vm.organization_contacts[org_id].push(contact);
                })
            })
        }

        function org_name(org_id) {
            var org = vm.organizations.find('organization', org_id);
            if(org)
                return org.name;
            return org_id;
        }
    }
})();