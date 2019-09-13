import React, { useContext } from 'react';
import { useTranslation } from 'react-i18next';
import moment from 'moment';

import Card from '../../components/Card';
import { AppContext } from '../../../appContext';
import Table from '../../components/Table';
import ImpactInfo from '../../components/ImpactInfo';

import { GET_IMPACT_CHALLENGES, GET_CHALLENGES } from './queries';
// GET_IMPACT_CHALLENGES INTERFACES
import { impactReportStepsCount } from './__generated__/impactReportStepsCount';
// GET_CHALLENGES INTERFACES
import {
    communityChallenges,
    communityChallenges_community_communityChallenges_nodes as communityChallengesNodes,
} from './__generated__/communityChallenges';

const ChallengesPage = () => {
    const { t } = useTranslation('insights');
    const { orgId } = useContext(AppContext);

    const mapRows = (data: communityChallenges) => {
        const percentage = (a: number, b: number) => {
            const value = b === 0 ? 0 : Math.floor((a / b) * 100);
            return `${a} (${value}%)`;
        };

        const duration = (start: string, end: string) => {
            const startDate = moment(start).startOf('day');
            const endDate = moment(end).startOf('day');
            const days = Math.floor(
                moment.duration(endDate.diff(startDate)).asDays(),
            );
            return days === 1 ? '1 Day' : `${days} Days`;
        };

        const range = (start: string, end: string) => {
            const format = 'MM/DD/YYYY';
            const startDate = moment(start).format(format);
            const endDate = moment(end).format(format);
            return `${startDate} - ${endDate}`;
        };

        return data.community.communityChallenges.nodes.map(
            ({
                id,
                title,
                acceptedCount,
                completedCount,
                createdAt,
                endDate,
            }: communityChallengesNodes) => [
                id,
                title,
                acceptedCount,
                percentage(completedCount, acceptedCount),
                duration(createdAt, endDate),
                range(createdAt, endDate),
            ],
        );
    };

    const mapPage = (data: communityChallenges) => {
        return data.community.communityChallenges.pageInfo;
    };

    return (
        <div>
            <ImpactInfo
                query={GET_IMPACT_CHALLENGES}
                text={(report: impactReportStepsCount) =>
                    t('challenges.total', {
                        count: report.community.impactReport.stepsCount,
                    })
                }
                variables={{ id: orgId }}
            />
            <Card
                title={t('challenges.title')}
                subtitle={t('challenges.subTitle')}
                noPadding={true}
                noMarginBottom={true}
            >
                <Table
                    query={GET_CHALLENGES}
                    variables={{
                        id: orgId,
                        sortBy: 'createdAt_DESC',
                    }}
                    headers={[
                        '',
                        '',
                        t('challenges.join'),
                        t('challenges.completed'),
                        t('challenges.length'),
                        t('challenges.dates'),
                    ]}
                    mapRows={mapRows}
                    mapPage={mapPage}
                />
            </Card>
        </div>
    );
};

export default ChallengesPage;
