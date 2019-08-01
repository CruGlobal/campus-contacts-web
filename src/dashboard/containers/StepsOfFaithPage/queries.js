import gql from 'graphql-tag';

const GET_IMPACT_REPORT_TAKEN = gql`
    query impactReport($organizationId: ID!) {
        impactReport(organizationId: $organizationId) {
            stepsCount
            receiversCount
        }
    }
`;

const GET_TOTAL_STEPS_COMPLETED_REPORT = gql`
    query communityReport {
        communityReport {
            communityStagesReport {
                pathwayStage
                otherStepsCompletedCount
            }
        }
    }
`;

const GET_STEPS_COMPLETED_REPORT = gql`
    query communityReport {
        communityReport {
            dayReport {
                date
                stepsWithOthersStepsCompletedCount
                communityStagesReport {
                    pathwayStage
                    stepsWithOthersStepsCompletedCount
                }
            }
        }
    }
`;

const GET_STAGES_REPORT = gql`
    query organizationStagesReport(
        $period: String!
        $organizationId: ID!
        $endDate: ISO8601DateTime!
    ) {
        organizationStagesReport(
            period: $period
            organizationId: $organizationId
            endDate: $endDate
        ) {
            memberCount
            stage {
                name
            }
            othersStepsAddedCount
        }
    }
`;

const GET_IMPACT_REPORT_REACHED = gql`
    query impactReport($organizationId: ID!) {
        impactReport(organizationId: $organizationId) {
            stepsCount
        }
    }
`;

const GET_STAGES_PEOPLE_REPORT = gql`
    query organizationStagesReport(
        $period: String!
        $organizationId: ID!
        $endDate: ISO8601DateTime!
    ) {
        organizationStagesReport(
            period: $period
            organizationId: $organizationId
            endDate: $endDate
        ) {
            memberCount
            stage {
                name
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
