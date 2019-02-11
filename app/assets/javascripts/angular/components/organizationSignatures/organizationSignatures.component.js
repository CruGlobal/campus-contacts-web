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
    this.itemsPerPage = 50;
    this.isLoading = true;

    const getSignatures = (orgId, searchText, offset) => {
        const params = {
            include: [],
            'page[limit]': this.itemsPerPage,
            ...(searchText ? { 'filters[q]': searchText } : {}),
            ...(offset ? { 'page[offset]': offset } : {}),
        };

        return httpProxy.get(`/organizations/${orgId}/signatures`, params, {
            errorMessage: 'error.messages.surveys.loadQuestions',
        });
    };

    const prepareData = data =>
        data.map(signature => ({
            first_name: signature.first_name,
            last_name: signature.last_name,
            updated_at: signature.updated_at,
            code_of_conduct: signature.code_of_conduct,
            statement_of_faith: signature.statement_of_faith,
            organization_name: signature.organization.name,
        }));

    const buildExportCsvLink = searchText => {
        const params = {
            access_token: $http.defaults.headers.common.Authorization.slice(7),
            include: '',
            format: 'csv',
            ...(searchText ? { 'filters[q]': searchText } : {}),
        };

        const query = Object.entries(params).reduce(
            (accumulator, [key, value]) => {
                return `${accumulator}&${encodeURIComponent(
                    key,
                )}=${encodeURIComponent(value)}`;
            },
            '',
        );

        return (
            envService.read('apiUrl') +
            `/organizations/${this.orgId}/signatures?${query}`
        );
    };

    const loadData = async (tableState, searchText) => {
        this.isLoading = true;
        this.signatures = [];
        const start = (tableState && tableState.pagination.start) || 0;
        const { data, meta } = await getSignatures(
            this.orgId,
            searchText,
            start,
        );
        const numberOfPages = Math.ceil(meta.total / this.itemsPerPage);

        this.signatureData = prepareData(data);
        this.signatures = [...this.signatureData];
        this.exportLink = buildExportCsvLink(searchText);

        tableState.pagination.numberOfPages = numberOfPages;
        tableState.pagination.currentPage =
            Math.ceil(start / this.itemsPerPage) + 1;
        tableState.pagination.pages = [];

        for (let i = 0; i < numberOfPages; i++) {
            tableState.pagination.pages.push(i);
        }

        tableState.pagination.totalItemCount = meta.total;
        this.tableState = tableState;
        this.isLoading = false;
        $scope.$apply();
    };

    this.setPage = (page, searchText) => {
        this.tableState.pagination.start = page * this.itemsPerPage;
        loadData(this.tableState, searchText);
    };

    this.nextPage = searchText => {
        this.tableState.pagination.start =
            this.tableState.pagination.currentPage * this.itemsPerPage;
        loadData(this.tableState, searchText);
    };

    this.previousPage = searchText => {
        this.tableState.pagination.start =
            (this.tableState.pagination.currentPage - 2) * this.itemsPerPage;
        loadData(this.tableState, searchText);
    };

    this.load = tableState => {
        tableState.pagination.numberOfPages = 0;
        this.tableState = tableState;
        loadData(tableState);
    };

    this.search = (searchText, tableState) => {
        tableState.pagination.start = 0;
        loadData(tableState, searchText);
    };
}
