import gql from 'graphql-tag';

const GET_IMPACT_REPORT_TAKEN = gql`
    query impactReportOtherStepsCompleted($id: ID!) {
        community(id: $id) {
            impactReport {
                othersStepsCompletedCount
                othersStepsReceiversCompletedCount
            }
        }
    }
`;

const GET_TOTAL_STEPS_COMPLETED_REPORT = gql`
    query communityReportStagesOthersStepsCompleted(
        $period: String!
        $id: ID!
        $endDate: ISO8601DateTime!
    ) {
        community(id: $id) {
            report(period: $period, endDate: $endDate) {
                stagesReport {
                    othersStepsCompletedCount
                    stage {
                        name
                    }
                }
            }
        }
    }
`;

const GET_STEPS_COMPLETED_REPORT = gql`
    query communityReportDaysOthersSteps(
        $period: String!
        $id: ID!
        $endDate: ISO8601DateTime!
    ) {
        community(id: $id) {
            report(period: $period, endDate: $endDate) {
                daysReport {
                    date
                    othersStepsCompletedCount
                    stageResults {
                        othersStepsCompletedCount
                        stage {
                            name
                        }
                    }
                }
            }
        }
    }
`;

const GET_STAGES_REPORT = gql`
    query communityReportStagesOthersStepsAdded(
        $period: String!
        $id: ID!
        $endDate: ISO8601DateTime!
    ) {
        community(id: $id) {
            report(period: $period, endDate: $endDate) {
                stagesReport {
                    othersStepsAddedCount
                    stage {
                        name
                    }
                }
            }
        }
    }
`;

const GET_IMPACT_REPORT_REACHED = gql`
    query impactReportMembersStageProgressionCount($id: ID!) {
        community(id: $id) {
            impactReport {
                membersStageProgressionCount
            }
        }
    }
`;

const GET_STAGES_PEOPLE_REPORT = gql`
    query communityReportStagesOthersContactCount(
        $period: String!
        $id: ID!
        $endDate: ISO8601DateTime!
    ) {
        community(id: $id) {
            report(period: $period, endDate: $endDate) {
                stagesReport {
                    contactCount
                    stage {
                        name
                    }
                }
            }
        }
    }
`;

export {
    GET_IMPACT_REPORT_TAKEN,
    GET_IMPACT_REPORT_REACHED,
    GET_TOTAL_STEPS_COMPLETED_REPORT,
    GET_STEPS_COMPLETED_REPORT,
    GET_STAGES_REPORT,
    GET_STAGES_PEOPLE_REPORT,
};
