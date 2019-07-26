import gql from 'graphql-tag';

const GET_IMPACT_REPORT_MOVED = gql`
    query impactReport($organizationId: ID!) {
        impactReport(organizationId: $organizationId) {
            pathwayMovedCount
        }
    }
`;

const GET_IMPACT_REPORT_STEPS_TAKEN = gql`
    query impactReport($organizationId: ID!) {
        impactReport(organizationId: $organizationId) {
            stepOwnersCount
        }
    }
`;

const GET_STAGES_REPORT_MEMBER_COUNT = gql`
    query organizationPathwayStagesReport(
        $period: String!
        $organizationId: ID!
        $endDate: ISO8601DateTime!
    ) {
        organizationPathwayStagesReport(
            period: $period
            organizationId: $organizationId
            endDate: $endDate
        ) {
            memberCount
            pathwayStage {
                name
            }
        }
    }
`;

const GET_STAGES_REPORT_STEPS_ADDED = gql`
    query organizationPathwayStagesReport(
        $period: String!
        $organizationId: ID!
        $endDate: ISO8601DateTime!
    ) {
        organizationPathwayStagesReport(
            period: $period
            organizationId: $organizationId
            endDate: $endDate
        ) {
            pathwayStage {
                name
            }
            stepsAddedCount
        }
    }
`;

const GET_STEPS_COMPLETED_REPORT = gql`
    query communityReport {
        communityReport {
            dayReport {
                date
                personalStepsCompletedCount
                communityStagesReport {
                    pathwayStage
                    personalStepsCompletedCount
                }
            }
        }
    }
`;

const GET_TOTAL_STEPS_COMPLETED_SUMMARY = gql`
    query communityReport {
        communityReport {
            communityStagesReport {
                pathwayStage
                personalStepsCompletedCount
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