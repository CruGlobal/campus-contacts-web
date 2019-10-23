import React, { useContext } from 'react';
import { useTranslation } from 'react-i18next';
import moment from 'moment';

import Card from '../../components/Card';
import { AppContext } from '../../../appContext';
import StagesSummary from '../../components/StagesSummary';
import ImpactInfo from '../../components/ImpactInfo';
import FiltersChart from '../../components/FiltersChart';

import {
    INTERACTIONS_TOTAL_REPORT,
    INTERACTIONS_TOTAL_COMPLETED_REPORT,
    INTERACTIONS_COMPLETED_REPORT,
} from './queries';
// INTERACTIONS_TOTAL_REPORT INTERFACES
import { impactReportInteractionsCount } from './__generated__/impactReportInteractionsCount';
// INTERACTIONS_TOTAL_COMPLETED_REPORT INTERFACES
import {
    communityReportInteractions,
    communityReportInteractions_community_report_interactions as communityReportInteractionsEntry,
} from './__generated__/communityReportInteractions';
// INTERACTIONS_COMPLETED_REPORT INTERFACES
import {
    communityReportDaysInteractions,
    communityReportDaysInteractions_community_report_daysReport as communityReportDaysInteractionsRow,
    communityReportDaysInteractions_community_report_daysReport_interactionResults as communityReportDaysInteractionsStage,
} from './__generated__/communityReportDaysInteractions';

const InteractionsPage = () => {
    const { t } = useTranslation('insights');
    const { orgId } = useContext(AppContext);

    return (
        <div>
            <ImpactInfo
                query={INTERACTIONS_TOTAL_REPORT}
                text={(report: impactReportInteractionsCount) =>
                    t('interactions.taken', {
                        count: report.community.impactReport.interactionsCount,
                        people:
                            report.community.impactReport
                                .interactionsReceiversCount,
                    })
                }
                variables={{ id: orgId }}
            />
            <Card title={t('interactions.totalCompleted')}>
                <StagesSummary
                    query={INTERACTIONS_TOTAL_COMPLETED_REPORT}
                    variables={{ id: orgId }}
                    longNames={true}
                    mapData={(data: communityReportInteractions) =>
                        data.community.report.interactions.map(
                            (entry: communityReportInteractionsEntry) => ({
                                stage: entry.interactionType.name,
                                icon: entry.interactionType.name
                                    .toLowerCase()
                                    .split(' ')
                                    .join('-'),
                                count: entry.interactionCount,
                            }),
                        )
                    }
                />
            </Card>
            <Card
                title={t('interactions.completed')}
                subtitle={t('interactions.completedSubtitle')}
            >
                <FiltersChart
                    nullContent={'interactionsCompleted'}
                    query={INTERACTIONS_COMPLETED_REPORT}
                    variables={{ id: orgId }}
                    mapData={(data: communityReportDaysInteractions) =>
                        data.community.report.daysReport.map(
                            (row: communityReportDaysInteractionsRow) => ({
                                ['total']: row.interactionsCount,
                                ['stages']: row.interactionResults.map(
                                    (
                                        stage: communityReportDaysInteractionsStage,
                                    ) => ({
                                        name: stage.interactionType.name,
                                        count: stage.count,
                                    }),
                                ),
                                ['date']: row.date,
                            }),
                        )
                    }
                    currentDate={moment().toDate()}
                    label={t('interactions.legend')}
                />
            </Card>
        </div>
    );
};

export default InteractionsPage;
