// From https://github.com/emotion-js/emotion/issues/1320#issuecomment-523123548
import { CreateStyled } from '@emotion/styled/types/index';

import { MissionHubTheme } from '../../src/missionhubTheme';
export * from '@emotion/styled/types/index';
const customStyled: CreateStyled<MissionHubTheme>;
export default customStyled;
