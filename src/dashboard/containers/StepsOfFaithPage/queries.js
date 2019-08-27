import gql from 'graphql-tag';

const GET_IMPACT_REPORT_TAKEN = gql`
    query impactReport($id: ID!) {
        community(id: $id) {
            impactReport {
                othersStepsCompletedCount
                othersStepsReceiversCompletedCount
            }
        }
    }
`;

const GET_TOTAL_STEPS_COMPLETED_REPORT = gql`
    query communityStagesReport(
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
    query communityDayReport(
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
    query communityStagesReport(
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
    query impactReport($id: ID!) {
        community(id: $id) {
            impactReport {
                membersStageProgressionCount
            }
        }
    }
`;

const GET_STAGES_PEOPLE_REPORT = gql`
    query communityStagesReport(
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
