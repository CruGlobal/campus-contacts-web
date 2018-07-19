import { getNamesOfLoadedTranslations } from './user-preferences.service';

describe('getNamesOfLoadedTranslations', () => {
    it('should load the English locale', () => {
        expect(getNamesOfLoadedTranslations()).toEqual([
            { code: 'en-US', name: 'English - American (en-US)' },
        ]);
    });
});
