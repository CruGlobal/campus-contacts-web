import React, { useContext } from 'react';
import { useTranslation } from 'react-i18next';
import moment from 'moment';
import _ from 'lodash';

import Card from '../../components/Card';
import AppContext from '../../appContext';
import StagesSummary from '../../components/StagesSummary';
import ImpactInfo from '../../components/ImpactInfo';
import FiltersChart from '../../components/FiltersChart';

import {
    INTERACTIONS_TOTAL_REPORT,
    INTERACTIONS_TOTAL_COMPLETED_REPORT,
    INTERACTIONS_COMPLETED_REPORT,
} from './queries';

const InteractionsPage = () => {
    const { t } = useTranslation('insights');
    const { orgId } = useContext(AppContext);

    return (
        <div>
            <ImpactInfo
                query={INTERACTIONS_TOTAL_REPORT}
                text={report =>
                    t('interactions.taken', {
                        count:
                            report.communityReport.impactReport
                                .interactionsCount,
                        people:
                            report.communityReport.impactReport
                                .interactionsReceiversCount,
                    })
                }
                variables={{ organizationId: orgId }}
            />
            <Card title={t('interactions.totalCompleted')}>
                <StagesSummary
                    query={INTERACTIONS_TOTAL_COMPLETED_REPORT}
                    variables={{
                        organizationId: orgId,
                    }}
                    mapData={data =>
                        data.communityReport.interactions.map(entry => ({
                            stage: entry.interactionType.name,
                            icon: entry.interactionType.name
                                .toLowerCase()
                                .split(' ')
                                .join('-'),
                            count: entry.interactionCount,
                        }))
                    }
                />
            </Card>
            <Card
                title={t('interactions.completed')}
                subtitle={t('interactions.completedSubtitle')}
            >
                <FiltersChart
                    query={INTERACTIONS_COMPLETED_REPORT}
                    mapData={data =>
                        data.communityReport.dayReport.map(row => ({
                            ['total']: row.interactionCount,
                            ['stages']: row.interactions.map(stage => ({
                                name: stage.interactionType.name,
                                count: stage.interactionCount,
                            })),
                            ['date']: row.date.substring(0, 2),
                        }))
                    }
                    countAverage={data =>
                        Math.floor(_.sumBy(data, 'total') / data.length)
                    }
                    label={t('interactions.legend')}
                />
            </Card>
        </div>
    );
};

export default InteractionsPage;

InteractionsPage.propTypes = {};
