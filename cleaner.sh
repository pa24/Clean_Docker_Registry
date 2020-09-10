# этот скрипт удаляет удаляет старые версии тегов,                                      #
#оставляя 10 последних версий (переменная NUM-DEEP, можно поменять)                     #
#строки удаления rm -rf  и garbage-collect по-умолчанию закомментированы,               #
# можно запустить в пробном режиме и посмотреть какие теги будут удалены.               #
#########################################################################################

#перенаправление вывода в файл
#exec 1>log
NUM_DEEP=10
REPOPATH=/data/registry/docker/registry/v2/repositories/
TAG_COUNT=0
DU_BEFORE=$(du -sh /data/registry)
#нахожу название репозиториев прим: aa-provider
for repo_path in $REPOPATH*; do
        repo=$(basename $repo_path)
        echo "*******************************************************"
        echo "repo: $repo"
        VERSIONPATH=$REPOPATH$repo/_manifests/tags/
        # нахожу название всех версий; прим: latest.claim, latest.master и т.д.
        for version_path in $VERSIONPATH/*; do
                version=$(basename $version_path)
                echo "version: $version"
                TAGPATH=$REPOPATH$repo/_manifests/tags/$version/index/sha256
                REVPATH=$REPOPATH$repo/_manifests/revisions/sha256
                #отсортировываю хеш по времени изменения. Новые вначале.
                #Будут удалены все теги после 10-го (переменная NUM_DEEP)
                # Т.е. 10 версий остаются, а более старые удаляются.
                for hash in $(ls $TAGPATH -t | tail -n +$NUM_DEEP)
                        do
                        TAG_COUNT=$((TAG_COUNT+1))
                        echo "удалены из tags"  $TAGPATH/$hash;
                        #sudo rm -rf $TAGPATH/$hash;
                        echo "удалены из revisions" $REVPATH/$hash;
                        #sudo rm -rf $REVPATH/$hash;
                done
        done
done
#sudo docker exec -it  registry bin/registry garbage-collect -m /etc/docker/registry/config.yml
DU_AFTER=$(du -sh /data/registry)

echo -e "\n\n################################################"
echo "Удалено $TAG_COUNT тегов"
echo "размер регистри до очистки: $DU_BEFORE"
