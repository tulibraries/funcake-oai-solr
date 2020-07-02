# Funnel Cake OAI (funcake-oai) Solr Configurations
[![CircleCI](https://circleci.com/gh/tulibraries/funcake-oai-solr.svg?style=svg)](https://circleci.com/gh/tulibraries/funcake-oai-solr)

These are the Solr configuration files for the Funnel Cake (PA Digital) OAI endpoint.

## Prerequisites

- These configurations are built for Solr 8.1
- The instructions below presume a SolrCloud multi-node setup (using an external Zookeeper)

## Local Testing / Development

You need a local SolrCloud cluster running to load these into. For example, use the make commands + docker-compose file in https://github.com/tulibraries/ansible-playbook-solrcloud to start a cluster. That repository's makefile includes this set of configurations and collection (funcake) in its `make create-release-collections` and `make create-aliases` commands.

If you want to go through those steps yourself, once you have a working SolrCloud cluster:

1. clone this repository locally & change into the top level directory of the repository

```
$ git clone https://github.com/tulibraries/funcake-oai-solr.git
$ cd funcake-oai-solr
```

2. zip the contents of this repository *without* the top-level directory

```
$ zip -r - * > funcake-oai.zip
```

3. load the configs zip file into a new SolrCloud ConfigSet (change the solr url to whichever solr you're developing against)

```
$ curl -X POST --header "Content-Type:application/octet-stream" --data-binary @funcake-oai.zip "http://localhost:8081/solr/admin/configs?action=UPLOAD&name=funcake-oai"
```

4. create a new SolrCloud Collection using that ConfigSet (change the solr url to whichever solr you're developing against)

```
$ curl "http://localhost:8090/solr/admin/collections?action=CREATE&name=funcake-1&numShards=1&replicationFactor=2&maxShardsPerNode=1&collection.configName=funcake-oai"
```

5. create a new SolrCloud Alias pointing to that Collection (if you want to use an Alias; and change the solr url to whatever solr you're developing against):

```
$ curl "http://localhost:8090/solr/admin/collections?action=CREATEALIAS&name=funcake-oai-1-dev&collections=funcake-oai-1"
```

## SolrCloud Deployment

All PRs merged into the `main` branch are _not_ deployed anywhere. Only releases are deployed.

### Production

Once the main branch has been adequately tested and reviewed, a release is cut. Upon creating the release tag (generally just an integer), the following occurs:
1. new ConfigSet of `funcake-oai-{release-tag}` is created in [Production SolrCloud](https://solrcloud.tul-infra.page);
2. new Collection of `funcake-oai-{release-tag}-init` is created in [Production SolrCloud](https://solrcloud.tul-infra.page) w/the requisite ConfigSet (this Collection is largely ignored);
3. a new Dev alias of `funcake-oai-{release-tag}-dev` is created in [Production SolrCloud](https://solrcloud.tul-infra.page), pointing to the init Collection;
3. a new Prod alias of `funcake-oai-{release-tag}-prod` is created in [Production SolrCloud](https://solrcloud.tul-infra.page), pointing to the init Collection;
4. and, manually, a full reindex DAG is kicked off from Airflow Production to this new funcake-oai alias. Upon completion of the reindex, relevant clients are redeployed pointing at their new alias, and *then QA & UAT review occur*.

See the process outlined here: https://github.com/tulibraries/docs/blob/main/services/solrcloud.md

After some time (1-4 days, as needed), the older funcake-oai collections are manually removed from Prod SolrCloud.
