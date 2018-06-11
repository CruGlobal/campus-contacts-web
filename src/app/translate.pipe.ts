import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 't',
})
export class TranslatePipe implements PipeTransform {
  transform(value: any, args?: any): any {
    return value;
  }
}
