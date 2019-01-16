import template from './organizationSignatures.html';
import './organizationSignatures.scss';

angular.module('missionhubApp').component('organizationSignatures', {
    bindings: {
        orgId: '<',
    },
    template: template,
    controller: organizationSignaturesController,
});

function organizationSignaturesController(
    httpProxy,
    $scope,
    $window,
    envService,
    $http,
) {
    this.signatures = [];
    this.signatureData = [];
    this.exportLink = '';
    this.itemsPerPage = 10;

    const getSignatures = (orgId, searchText) => {
        const params = {
            include: [],
            ...(searchText ? { 'filters[q]': searchText } : {}),
        };

        return httpProxy.get(`/organizations/${orgId}/signatures`, params, {
            errorMessage: 'error.messages.surveys.loadQuestions',
        });
    };

    const prepareData = data => {
        return data.map(data => {
            return {
                first_name: data.first_name,
                last_name: data.last_name,
                updated_at: data.updated_at,
                code_of_conduct: data.code_of_conduct,
                statement_of_faith: data.statement_of_faith,
            };
        });
    };

    const buildExportCsvLink = searchText => {
        const params = {
            access_token: $http.defaults.headers.common.Authorization.slice(7),
            include: '',
            format: 'csv',
            ...(searchText ? { 'filters[q]': searchText } : {}),
        };

        const query = Object.keys(params).reduce((accumulator, key, index) => {
            return (
                accumulator +
                '&' +
                encodeURIComponent(key) +
                '=' +
                encodeURIComponent(params[key])
            );
        }, '');

        return (
            envService.read('apiUrl') +
            `/organizations/${this.orgId}/signatures?${query}`
        );
    };

    const loadData = async searchText => {
        const { data } = await getSignatures(this.orgId, searchText);
        this.signatureData = prepareData(data);
        this.signatures = [].concat(prepareData(data));
        this.exportLink = buildExportCsvLink(searchText);
        $scope.$apply();
    };

    this.load = () => {
        loadData();
    };

    this.search = searchText => {
        loadData(searchText);
    };
}
