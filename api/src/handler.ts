import { APIGatewayProxyHandler } from 'aws-lambda'
import Axios from 'axios'
import moment from 'moment-timezone'

import { newResultDecorator, HttpReturnCode } from './handler-util'

const r = newResultDecorator('https://sansan.jabara.info')

export const options = r.options

export const getCardCount: APIGatewayProxyHandler = async (evt) => {
  if (!('x-sansan-api-key' in evt.headers)) {
    return r.general(HttpReturnCode.BAD_REQUEST)
  }
  if (!evt.queryStringParameters) {

  }
  const term = getTerm(evt.queryStringParameters)
  const res = await Axios.get(`https://api.sansan.com/v2.2/bizCards?updatedFrom=${term.updatedFrom}T00%3a00%3a00%2b09%3a00&updatedTo=${term.updatedTo}T00%3a00%3a00%2b09%3a00&limit=300`, {
    headers: {
      'x-sansan-api-key': evt.headers['x-sansan-api-key'],
    },
  })
  return r.ok({ count: res.data.data.length })
}

interface Term {
  updatedFrom: string;
  updatedTo: string;
}

function getTerm(params: { [name: string]: string } | null): Term {
  if (!params) {
    const now = moment()
    return {
      updatedFrom: now.format('YYYY-MM-DD'),
      updatedTo: now.format('YYYY-MM-DD'),
    }
  }
  return {
    updatedFrom: params.updatedFrom,
    updatedTo: params.updatedTo,
  }
}