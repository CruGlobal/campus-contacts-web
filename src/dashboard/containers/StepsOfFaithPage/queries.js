import gql from 'graphql-tag';

const GET_IMPACT_REPORT_TAKEN = gql`
    query impactReport($communityId: ID!) {
        impactReport(communityId: $communityId) {
            othersStepsCompletedCount
            othersStepsReceiversCompletedCount
        }
    }
`;

const GET_TOTAL_STEPS_COMPLETED_REPORT = gql`
    query communityStagesReport(
        $period: String!
        $communityIds: [ID!]
        $endDate: ISO8601DateTime!
    ) {
        communitiesReport(
            period: $period
            communityIds: $communityIds
            endDate: $endDate
        ) {
            stagesReport {
                othersStepsCompletedCount
                stage {
                    name
                }
            }
        }
    }
`;

const GET_STEPS_COMPLETED_REPORT = gql`
    query communityDayReport(
        $period: String!
        $communityIds: [ID!]
        $endDate: ISO8601DateTime!
    ) {
        communitiesReport(
            period: $period
            communityIds: $communityIds
            endDate: $endDate
        ) {
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
`;

const GET_STAGES_REPORT = gql`
    query communityStagesReport(
        $period: String!
        $communityIds: [ID!]
        $endDate: ISO8601DateTime!
    ) {
        communitiesReport(
            period: $period
            communityIds: $communityIds
            endDate: $endDate
        ) {
            stagesReport {
                othersStepsAddedCount
                stage {
                    name
                }
            }
        }
    }
`;

const GET_IMPACT_REPORT_REACHED = gql`
    query impactReport($communityId: ID!) {
        impactReport(communityId: $communityId) {
            stepsCount
        }
    }
`;

const GET_STAGES_PEOPLE_REPORT = gql`
    query communityStagesReport(
        $period: String!
        $communityIds: [ID!]
        $endDate: ISO8601DateTime!
    ) {
        communitiesReport(
            period: $period
            communityIds: $communityIds
            endDate: $endDate
        ) {
            stagesReport {
                memberCount
                stage {
                    name
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
