import gql from 'graphql-tag';

const GET_IMPACT_REPORT_MOVED = gql`
    query impactReportStageProgressionCount($id: ID!) {
        community(id: $id) {
            impactReport {
                stageProgressionCount
            }
        }
    }
`;

const GET_IMPACT_REPORT_STEPS_TAKEN = gql`
    query impactReportPersonalStepsCompletedCount($id: ID!) {
        community(id: $id) {
            impactReport {
                personalStepsCompletedCount
            }
        }
    }
`;

const GET_STAGES_REPORT_MEMBER_COUNT = gql`
    query communityReportStagesPersonalMemberCount(
        $period: String!
        $id: ID!
        $endDate: ISO8601DateTime!
    ) {
        community(id: $id) {
            report(period: $period, endDate: $endDate) {
                stagesReport {
                    nodes {
                        memberCount
                        stage {
                            name
                        }
                    }
                }
            }
        }
    }
`;

const GET_STAGES_REPORT_STEPS_ADDED = gql`
    query communityReportStagesPersonalStepsAdded(
        $period: String!
        $id: ID!
        $endDate: ISO8601DateTime!
    ) {
        community(id: $id) {
            report(period: $period, endDate: $endDate) {
                stagesReport {
                    nodes {
                        personalStepsAddedCount
                        stage {
                            name
                        }
                    }
                }
            }
        }
    }
`;

const GET_STEPS_COMPLETED_REPORT = gql`
    query communityReportDaysPersonalSteps(
        $period: String!
        $id: ID!
        $endDate: ISO8601DateTime!
    ) {
        community(id: $id) {
            report(period: $period, endDate: $endDate) {
                daysReport {
                    nodes {
                        date
                        personalStepsCompletedCount
                        stageResults {
                            nodes {
                                personalStepsCompletedCount
                                stage {
                                    name
                                }
                            }
                        }
                    }
                }
            }
        }
    }
`;

const GET_TOTAL_STEPS_COMPLETED_SUMMARY = gql`
    query communityReportStagesPersonalStepsCompleted(
        $id: ID!
        $period: String!
        $endDate: ISO8601DateTime!
    ) {
        community(id: $id) {
            report(period: $period, endDate: $endDate) {
                stagesReport {
                    nodes {
                        personalStepsCompletedCount
                        stage {
                            name
                        }
                    }
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
