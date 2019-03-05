import { APIGatewayProxyHandler } from 'aws-lambda'
import Axios from 'axios'

import { newResultDecorator } from './handler-util'

const r = newResultDecorator('https://sansan-card-counter.jabara.info')

export const getCards: APIGatewayProxyHandler = async (evt) => {
  const res = await Axios.get('https://api.sansan.com/v2.2/bizCards?updatedFrom=2015-08-21T11%3a29%3a39%2b09%3a00&updatedTo=2015-08-22T11%3a29%3a39%2b09%3a00', {
    headers: {
      'X-Sansan-Api-Key': evt.headers['X-Sansan-Api-Key'],
    },
  })
  return r.ok(res.data)
}