import 'angular-mocks';

// Constants
var surveyService, $rootScope, httpProxy;

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

describe('surveyService', function() {
    beforeEach(angular.mock.module('missionhubApp'));

    beforeEach(inject(function(_surveyService_, _$rootScope_, $q, _httpProxy_) {
        surveyService = _surveyService_;
        $rootScope = _$rootScope_;
        httpProxy = _httpProxy_;

        this.survey = {
            _type: 'survey',
            id: 11,
            attributes: {
                title: 'Survey 1',
                is_frozen: false,
            },
        };

        var _this = this;

        this.httpResponse = {
            data: this.survey,
        };
        spyOn(httpProxy, 'callHttp').and.callFake(function() {
            return $q.resolve(_this.httpResponse);
        });
    }));

    describe('createSurvey', function() {
        it('should make a network request', function() {
            surveyService.createSurvey(this.survey);
            expect(httpProxy.callHttp).toHaveBeenCalled();
        });

        it(
            'should return a promise that resolves to the new survey',
            asynchronous(function() {
                var _this = this;
                return surveyService
                    .createSurvey(this.survey)
                    .then(function(survey) {
                        expect(survey).toBe(_this.survey);
                    });
            }),
        );
    });

    describe('updateSurvey', function() {
        it('should make a network request', function() {
            surveyService.updateSurvey(this.survey);
            expect(httpProxy.callHttp).toHaveBeenCalled();
        });

        it(
            'should return a promise that resolves to the updated survey',
            asynchronous(function() {
                var _this = this;
                return surveyService
                    .updateSurvey(this.survey)
                    .then(function(survey) {
                        expect(survey).toBe(_this.survey);
                    });
            }),
        );
    });

    describe('deleteSurvey', function() {
        it('should make a network request', function() {
            surveyService.deleteSurvey(this.survey);
            expect(httpProxy.callHttp).toHaveBeenCalled();
        });
    });
});
