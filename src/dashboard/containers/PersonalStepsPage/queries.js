import gql from 'graphql-tag';

const GET_IMPACT_REPORT_MOVED = gql`
    query impactReport($communityId: ID!) {
        impactReport(communityId: $communityId) {
            stageProgressionCount
        }
    }
`;

const GET_IMPACT_REPORT_STEPS_TAKEN = gql`
    query impactReport($communityId: ID!) {
        impactReport(communityId: $communityId) {
            personalStepsCompletedCount
        }
    }
`;

const GET_STAGES_REPORT_MEMBER_COUNT = gql`
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

const GET_STAGES_REPORT_STEPS_ADDED = gql`
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
                personalStepsAddedCount
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
                personalStepsCount
                stageResults {
                    personalSteps
                    stage {
                        name
                    }
                }
            }
        }
    }
`;

const GET_TOTAL_STEPS_COMPLETED_SUMMARY = gql`
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
                personalStepsCompletedCount
                stage {
                    name
                }
            }
        }
    }
`;

export {
    GET_IMPACT_REPORT_MOVED,
    GET_IMPACT_REPORT_STEPS_TAKEN,
    GET_STAGES_REPORT_MEMBER_COUNT,
    GET_STEPS_COMPLETED_REPORT,
    GET_STAGES_REPORT_STEPS_ADDED,
    GET_TOTAL_STEPS_COMPLETED_SUMMARY,
};
