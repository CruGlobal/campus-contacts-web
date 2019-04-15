import gql from 'graphql-tag';

export const GET_STEPS_COMPLETED_GRAPHQL = gql`
    query {
        organization(id: 2) {
            id
            stage_0: stageReport(pathwayStageId: 6) {
                id
                pathwayStage {
                    name
                    description
                }
                stepsAddedCount
                stepsCompletedCount
            }
            stage_1: stageReport(pathwayStageId: 1) {
                id
                pathwayStage {
                    name
                    description
                }
                stepsAddedCount
                stepsCompletedCount
            }
            stage_2: stageReport(pathwayStageId: 2) {
                id
                pathwayStage {
                    name
                    description
                }
                stepsAddedCount
                stepsCompletedCount
            }
            stage_3: stageReport(pathwayStageId: 3) {
                id
                pathwayStage {
                    name
                    description
                }
                stepsAddedCount
                stepsCompletedCount
            }
            stage_4: stageReport(pathwayStageId: 4) {
                id
                pathwayStage {
                    name
                    description
                }
                stepsAddedCount
                stepsCompletedCount
            }
            stage_5: stageReport(pathwayStageId: 5) {
                id
                pathwayStage {
                    name
                    description
                }
                stepsAddedCount
                stepsCompletedCount
            }
        }
    }
`;
